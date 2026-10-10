/* Aurora Glass — carrusel destacado en la portada de Jellyfin.
   Se carga desde index.html (ver install/inject-docker.sh). Solo lee la API con la sesión del usuario. */
(function () {
  'use strict';
  /* Ajustes: se leen de variables CSS (ponlas en «CSS personalizado», ver README) o de window.AuroraHero.
     Ejemplo:  :root { --ag-hero-count: 10; --ag-hero-source: toprated; --ag-hero-library: "Películas"; } */
  var DEF = {
    count: 8,                 // títulos en el carrusel (0 = sin carrusel)
    interval: 8,              // segundos entre diapositivas (0 = sin autoavance)
    source: 'recent',         // recent | random | toprated | favorites
    types: 'Movie,Series',    // Movie, Series o ambos
    library: '',              // nombre(s) de biblioteca separados por coma; vacío = todas
    days: 120,                // solo añadidos en los últimos N días (source=recent); 0 = sin límite
    unwatched: 1,             // 1 = solo no vistos
    logo: 1,                  // 1 = solo títulos con logo; 0 = también sin logo (muestra el nombre)
    overview: 1, genres: 1, rating: 1,
    buttons: 1,               // botones «Ver ahora» / «Más info»
    play: 1                   // 1 = «Ver ahora» reproduce directamente
  };
  var cache = null, cacheKey = null, cacheAt = 0;

  function cfg() {
    var c = {}, st = getComputedStyle(document.documentElement), ext = window.AuroraHero || {};
    Object.keys(DEF).forEach(function (k) {
      var v = ext[k] != null ? String(ext[k]) : st.getPropertyValue('--ag-hero-' + k).trim().replace(/^["']|["']$/g, '');
      if (v === '') { c[k] = DEF[k]; return; }
      c[k] = typeof DEF[k] === 'number' ? (parseFloat(v) || 0) : v;
    });
    return c;
  }

  function api() { return window.ApiClient; }
  function enHome() { if (/[?&]tab=[1-9]/.test(location.hash)) return false; return /^#\/home(\.html)?(\?|$)/.test(location.hash) || location.hash === '' || location.hash === '#/'; }

  function img(id, tipo, extra) {
    return api().getUrl('Items/' + id + '/Images/' + tipo + (extra || ''), { quality: 90, maxWidth: tipo === 'Logo' ? 700 : 1920 });
  }

  function bibliotecas(c, uid) {
    if (!c.library) return Promise.resolve([null]);
    var want = c.library.split(',').map(function (x) { return x.trim().toLowerCase(); });
    return api().getJSON(api().getUrl('Users/' + uid + '/Views')).then(function (r) {
      var ids = (r.Items || []).filter(function (v) { return want.indexOf((v.Name || '').toLowerCase()) >= 0; }).map(function (v) { return v.Id; });
      if (!ids.length) console.warn('[AuroraHero] no encuentro la biblioteca', c.library);
      return ids.length ? ids : [null];
    });
  }

  // nota para «toprated»: media de público y crítica; sin nota de crítica (títulos con pocos votos) penaliza
  function nota(i) { var p = i.CommunityRating || 0; return i.CriticRating ? (p + i.CriticRating / 10) / 2 : p - 2; }

  function cargar(c) {
    var a = api(), uid = a.getCurrentUserId(), key = uid + JSON.stringify(c);
    if (cache && cacheKey === key && Date.now() - cacheAt < 10 * 60 * 1000) return Promise.resolve(cache);
    var orden = { recent: 'DateCreated', toprated: 'CommunityRating', random: 'Random', favorites: 'Random' }[c.source] || 'DateCreated';
    return bibliotecas(c, uid).then(function (libs) {
      return Promise.all(libs.map(function (lib) {
        var q = {
          Recursive: true, IncludeItemTypes: c.types, ImageTypes: c.logo ? 'Backdrop,Logo' : 'Backdrop',
          Fields: 'Overview,Genres,ProductionYear,CommunityRating,OfficialRating,RunTimeTicks,ChildCount,ImageTags,BackdropImageTags,UserData',
          HasOverview: true, Limit: c.source === 'toprated' ? 150 : 40, SortBy: orden, SortOrder: 'Descending'
        };
        if (c.unwatched) q.IsPlayed = false;
        if (c.source === 'favorites') q.IsFavorite = true;
        if (c.source === 'recent' && c.days > 0) q.MinDateLastSaved = new Date(Date.now() - c.days * 864e5).toISOString();
        if (lib) q.ParentId = lib;
        return a.getJSON(a.getUrl('Users/' + uid + '/Items', q)).then(function (r) { return r.Items || []; });
      }));
    }).then(function (listas) {
      var items = [].concat.apply([], listas).filter(function (i) {
        return i.BackdropImageTags && i.BackdropImageTags.length && (!c.logo || (i.ImageTags && i.ImageTags.Logo));
      });
      // recent: mezcla priorizando nota alta; toprated: por nota; random/favorites: al azar
      if (c.source === 'toprated') items.sort(function (x, y) { return nota(y) - nota(x); });
      else if (c.source === 'recent') items.sort(function (x, y) { return (y.CommunityRating || 0) - (x.CommunityRating || 0) + (Math.random() - .5) * 3; });
      else items.sort(function () { return Math.random() - .5; });
      cache = items.slice(0, Math.max(1, c.count)); cacheKey = key; cacheAt = Date.now();
      return cache;
    });
  }

  function dur(t) { if (!t) return ''; var m = Math.round(t / 6e8); return m >= 60 ? Math.floor(m / 60) + ' h ' + (m % 60) + ' min' : m + ' min'; }
  function esc(s) { return String(s || '').replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }

  function construir(items, c) {
    var sid = api().serverId();
    var el = document.createElement('section');
    el.className = 'agHero';
    el.innerHTML =
      '<div class="agHero-slides">' + items.map(function (i, n) {
        var meta = [i.ProductionYear, i.Type === 'Series' ? (i.ChildCount ? i.ChildCount + (i.ChildCount === 1 ? ' temporada' : ' temporadas') : 'Serie') : dur(i.RunTimeTicks), i.OfficialRating]
          .filter(Boolean).map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('');
        if (c.rating && i.CommunityRating) meta += '<span class="agHero-star">★ ' + i.CommunityRating.toFixed(1) + '</span>';
        var gen = (c.genres ? i.Genres || [] : []).slice(0, 3).map(function (g) { return '<span class="agHero-chip">' + esc(g) + '</span>'; }).join('');
        var url = '#/details?id=' + i.Id + '&serverId=' + sid;
        return '<article class="agHero-slide' + (n === 0 ? ' is-active' : '') + '" data-i="' + n + '">' +
          '<div class="agHero-bg" style="background-image:url(\'' + img(i.Id, 'Backdrop', '/0') + '\')"></div>' +
          '<div class="agHero-shade"></div>' +
          '<div class="agHero-body">' +
            (i.ImageTags && i.ImageTags.Logo ? '<img class="agHero-logo" alt="' + esc(i.Name) + '" src="' + img(i.Id, 'Logo') + '">' : '<h2 class="agHero-title">' + esc(i.Name) + '</h2>') +
            '<div class="agHero-meta">' + meta + '</div>' +
            '<div class="agHero-genres">' + gen + '</div>' +
            (c.overview ? '<p class="agHero-overview">' + esc(i.Overview) + '</p>' : '') +
            (!c.buttons ? '' : '<div class="agHero-actions">' +
              '<a class="agHero-btn agHero-btn--main" data-play="' + i.Id + '" href="' + url + '"><span class="material-icons">play_arrow</span>Ver ahora</a>' +
              '<a class="agHero-btn" href="' + url + '"><span class="material-icons">info_outline</span>Más info</a>' +
            '</div>') +
          '</div></article>';
      }).join('') + '</div>' +
      '<button class="agHero-nav agHero-prev" aria-label="Anterior"><span class="material-icons">chevron_left</span></button>' +
      '<button class="agHero-nav agHero-next" aria-label="Siguiente"><span class="material-icons">chevron_right</span></button>' +
      '<div class="agHero-dots">' + items.map(function (_, n) { return '<button class="agHero-dot' + (n === 0 ? ' is-active' : '') + '" data-i="' + n + '" aria-label="Ir a ' + (n + 1) + '"><i></i></button>'; }).join('') + '</div>';

    var actual = 0, timer = null, slides = el.querySelectorAll('.agHero-slide'), dots = el.querySelectorAll('.agHero-dot');
    function ir(n) {
      n = (n + slides.length) % slides.length;
      slides[actual].classList.remove('is-active'); dots[actual].classList.remove('is-active');
      actual = n;
      slides[actual].classList.add('is-active');
      dots[actual].classList.remove('is-active'); void dots[actual].offsetWidth; dots[actual].classList.add('is-active');
    }
    var INTERVALO = c.interval * 1000;
    if (!INTERVALO) el.classList.add('is-static');
    function play() { stop(); if (!INTERVALO) return; timer = setInterval(function () { if (!document.hidden && document.body.contains(el)) ir(actual + 1); else if (!document.body.contains(el)) stop(); }, INTERVALO); el.classList.remove('is-paused'); }
    function stop() { if (timer) clearInterval(timer); timer = null; }
    el.querySelector('.agHero-prev').onclick = function () { ir(actual - 1); play(); };
    el.querySelector('.agHero-next').onclick = function () { ir(actual + 1); play(); };
    dots.forEach(function (d) { d.onclick = function () { ir(+d.dataset.i); play(); }; });
    el.addEventListener('mouseenter', function () { stop(); el.classList.add('is-paused'); });
    el.addEventListener('mouseleave', play);
    var x0 = null;
    el.addEventListener('touchstart', function (e) { x0 = e.touches[0].clientX; }, { passive: true });
    el.addEventListener('touchend', function (e) { if (x0 === null) return; var dx = e.changedTouches[0].clientX - x0; if (Math.abs(dx) > 50) { ir(actual + (dx < 0 ? 1 : -1)); play(); } x0 = null; });
    if (c.play) el.querySelectorAll('[data-play]').forEach(function (b) { b.addEventListener('click', function () { try { sessionStorage.setItem('agAutoplay', b.dataset.play); } catch (e) {} }); });
    el.style.setProperty('--ag-int', INTERVALO + 'ms');
    play();
    return el;
  }

  var montando = false;
  function montar() {
    if (!enHome() || !api() || !api().getCurrentUserId || !api().getCurrentUserId()) return;
    var page = document.querySelector('.homePage:not(.hide)');
    var cont = page && page.querySelector('.homeSectionsContainer');
    if (!cont || page.querySelector('.agHero') || montando) return;
    var c = cfg();
    if (c.count <= 0) return;
    montando = true;
    cargar(c).then(function (items) {
      montando = false;
      if (!items.length || page.querySelector('.agHero')) return;
      cont.parentNode.insertBefore(construir(items, c), cont);
    }).catch(function (e) { montando = false; console.warn('[AuroraHero]', e); });
  }

  // «Ver ahora»: al llegar a la ficha pulsa su botón de reproducir una sola vez
  function autoplay() {
    var id; try { id = sessionStorage.getItem('agAutoplay'); } catch (e) { return; }
    if (!id || location.hash.indexOf('id=' + id) < 0) return;
    var b = document.querySelector('.itemDetailPage:not(.hide) .mainDetailButtons .btnPlay:not(.hide)');
    if (!b) return;
    try { sessionStorage.removeItem('agAutoplay'); } catch (e) {}
    setTimeout(function () { b.click(); }, 350);
  }

  // El panel de administración de la 12.x no aplica el CSS personalizado: se lo ponemos nosotros
  var cssPedido = false;
  function cssPanel() {
    if (!/^#\/dashboard|^#\/(users|libraries|plugins|tasks|devices|activity|logs|playback|networking|branding|apikeys|livetv\/)/i.test(location.hash.replace('#!', '#'))) return;
    if (cssPedido || document.getElementById('agPanelCss')) return;
    var hay = Array.prototype.some.call(document.querySelectorAll('style'), function (s) { return s.id !== 'agPanelCss' && s.textContent.indexOf('Aurora Glass') >= 0; });
    if (hay) return;
    cssPedido = true;
    fetch(api().getUrl('Branding/Css')).then(function (r) { return r.text(); }).then(function (t) {
      var st = document.createElement('style'); st.id = 'agPanelCss'; st.textContent = t; document.head.appendChild(st);
    }).catch(function () { cssPedido = false; });
  }

  // Red de seguridad: Jellyfin cierra menús y diálogos al terminar su animación de salida («animationend»).
  // Si esa animación no llega a terminar (movimiento reducido, ahorro de energía, otro CSS…), el menú
  // se quedaba abierto tapando todo. Si medio segundo después de empezar a cerrarse sigue ahí, lo rematamos.
  document.addEventListener('closing', function (e) {
    var d = e.target;
    if (!d || !d.classList || !d.classList.contains('dialog')) return;
    setTimeout(function () {
      if (d.isConnected && !d.classList.contains('hide')) d.dispatchEvent(new Event('animationend'));
    }, 500);
  }, true);

  // Fallo de Jellyfin 12: los menús nuevos (MUI: «Más», usuario, panel…) no se cierran con el botón Atrás.
  // Al navegar se cambiaba de página pero el menú seguía montado con una capa invisible que bloqueaba todos
  // los toques (muy típico con el Atrás de Android). Al cambiar de página, los cerramos como si se tocara fuera.
  function cerrarMenusMui() {
    Array.prototype.forEach.call(document.querySelectorAll('.MuiModal-root:not(.MuiModal-hidden)'), function (m) {
      var b = m.querySelector('.MuiBackdrop-root');
      if (!b) return;
      ['mousedown', 'mouseup', 'click'].forEach(function (t) { b.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true })); });
    });
  }
  window.addEventListener('popstate', function () { setTimeout(cerrarMenusMui, 0); });
  window.addEventListener('hashchange', function () { setTimeout(cerrarMenusMui, 0); });

  var pend = false;
  new MutationObserver(function () {
    if (pend) return; pend = true;
    // en segundo plano no hay fotogramas (rAF congelado): usamos un temporizador
    (document.hidden ? function (f) { setTimeout(f, 50); } : requestAnimationFrame)(function () { pend = false; cssPanel(); if (enHome()) montar(); else autoplay(); });
  }).observe(document.documentElement, { childList: true, subtree: true });
  window.addEventListener('hashchange', function () { cssPanel(); montar(); });
})();
