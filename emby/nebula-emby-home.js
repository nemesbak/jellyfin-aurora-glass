/* Nebula para Emby — carrusel destacado en la portada.
   Se carga desde index.html (ver install/inject-docker.sh --emby). Solo lee la API con la sesión del usuario.
   Mismos ajustes que la versión de Jellyfin: variables --nb-hero-* en «CSS personalizado» o window.NebulaHero. */
(function () {
  'use strict';
  var DEF = {
    count: 8, interval: 8, source: 'recent', types: 'Movie,Series', library: '', days: 120,
    unwatched: 1, logo: 1, overview: 1, genres: 1, rating: 1, buttons: 1, play: 1
  };
  var cache = null, cacheKey = null, cacheAt = 0;

  function cfg() {
    var c = {}, st = getComputedStyle(document.documentElement), ext = window.NebulaHero || {};
    Object.keys(DEF).forEach(function (k) {
      var v = ext[k] != null ? String(ext[k]) : st.getPropertyValue('--nb-hero-' + k).trim().replace(/^["']|["']$/g, '');
      if (v === '') { c[k] = DEF[k]; return; }
      c[k] = typeof DEF[k] === 'number' ? (parseFloat(v) || 0) : v;
    });
    return c;
  }

  function api() { return window.ApiClient; }
  // portada de Emby: #!/home (sin pestaña de favoritos)
  function enHome() { return /^#!?\/home(\?|$)/.test(location.hash) && !/[?&]tab=[1-9]/.test(location.hash); }
  function vistaHome() {
    return document.querySelector('.view-home-home:not(.page-hidden):not(.hide)');
  }

  function img(id, tipo, extra) {
    return api().getUrl('Items/' + id + '/Images/' + tipo + (extra || ''), { quality: 90, maxWidth: tipo === 'Logo' ? 700 : 1920 });
  }

  function bibliotecas(c, uid) {
    if (!c.library) return Promise.resolve([null]);
    var want = c.library.split(',').map(function (x) { return x.trim().toLowerCase(); });
    return api().getJSON(api().getUrl('Users/' + uid + '/Views')).then(function (r) {
      var ids = (r.Items || []).filter(function (v) { return want.indexOf((v.Name || '').toLowerCase()) >= 0; }).map(function (v) { return v.Id; });
      if (!ids.length) console.warn('[NebulaHero] no encuentro la biblioteca', c.library);
      return ids.length ? ids : [null];
    });
  }

  function nota(i) { var p = i.CommunityRating || 0; return i.CriticRating ? (p + i.CriticRating / 10) / 2 : p - 2; }

  function cargar(c) {
    var a = api(), uid = a.getCurrentUserId(), key = uid + JSON.stringify(c);
    if (cache && cacheKey === key && Date.now() - cacheAt < 10 * 60 * 1000) return Promise.resolve(cache);
    var orden = { recent: 'DateCreated', toprated: 'CommunityRating', random: 'Random', favorites: 'Random' }[c.source] || 'DateCreated';
    var desde = c.source === 'recent' && c.days > 0 ? Date.now() - c.days * 864e5 : 0;
    return bibliotecas(c, uid).then(function (libs) {
      return Promise.all(libs.map(function (lib) {
        var q = {
          Recursive: true, IncludeItemTypes: c.types, ImageTypes: c.logo ? 'Backdrop,Logo' : 'Backdrop',
          Fields: 'Overview,Genres,ProductionYear,CommunityRating,CriticRating,OfficialRating,RunTimeTicks,ChildCount,DateCreated,BackdropImageTags,ImageTags',
          Limit: c.source === 'toprated' ? 150 : 60, SortBy: orden, SortOrder: 'Descending', EnableUserData: true
        };
        if (c.unwatched) q.IsPlayed = false;
        if (c.source === 'favorites') q.Filters = 'IsFavorite';
        if (lib) q.ParentId = lib;
        return a.getJSON(a.getUrl('Users/' + uid + '/Items', q)).then(function (r) { return r.Items || []; });
      }));
    }).then(function (listas) {
      var items = [].concat.apply([], listas).filter(function (i) {
        if (!i.Overview) return false;
        if (desde && i.DateCreated && Date.parse(i.DateCreated) < desde) return false;
        return i.BackdropImageTags && i.BackdropImageTags.length && (!c.logo || (i.ImageTags && i.ImageTags.Logo));
      });
      if (c.source === 'toprated') items.sort(function (x, y) { return nota(y) - nota(x); });
      else if (c.source === 'recent') items.sort(function (x, y) { return (y.CommunityRating || 0) - (x.CommunityRating || 0) + (Math.random() - .5) * 3; });
      else items.sort(function () { return Math.random() - .5; });
      cache = items.slice(0, Math.max(1, c.count)); cacheKey = key; cacheAt = Date.now();
      return cache;
    });
  }

  function dur(t) { if (!t) return ''; var m = Math.round(t / 6e8); return m >= 60 ? Math.floor(m / 60) + ' h ' + (m % 60) + ' min' : m + ' min'; }
  function esc(s) { return String(s || '').replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function icono(n) { return '<i class="md-icon nbHero-ico">' + n + '</i>'; }

  function construir(items, c) {
    var sid = api().serverId();
    var el = document.createElement('section');
    el.className = 'nbHero nbHero--emby';
    el.innerHTML =
      '<div class="nbHero-slides">' + items.map(function (i, n) {
        var meta = [i.ProductionYear, i.Type === 'Series' ? (i.ChildCount ? i.ChildCount + (i.ChildCount === 1 ? ' temporada' : ' temporadas') : 'Serie') : dur(i.RunTimeTicks), i.OfficialRating]
          .filter(Boolean).map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('');
        if (c.rating && i.CommunityRating) meta += '<span class="nbHero-star">★ ' + i.CommunityRating.toFixed(1) + '</span>';
        var gen = (c.genres ? i.Genres || [] : []).slice(0, 3).map(function (g) { return '<span class="nbHero-chip">' + esc(g) + '</span>'; }).join('');
        var url = '#!/item?id=' + i.Id + '&serverId=' + sid;
        return '<article class="nbHero-slide' + (n === 0 ? ' is-active' : '') + '" data-i="' + n + '">' +
          '<div class="nbHero-bg" style="background-image:url(\'' + img(i.Id, 'Backdrop', '/0') + '\')"></div>' +
          '<div class="nbHero-shade"></div>' +
          '<div class="nbHero-body">' +
            (i.ImageTags && i.ImageTags.Logo ? '<img class="nbHero-logo" alt="' + esc(i.Name) + '" src="' + img(i.Id, 'Logo') + '">' : '<h2 class="nbHero-title">' + esc(i.Name) + '</h2>') +
            '<div class="nbHero-meta">' + meta + '</div>' +
            '<div class="nbHero-genres">' + gen + '</div>' +
            (c.overview ? '<p class="nbHero-overview">' + esc(i.Overview) + '</p>' : '') +
            (!c.buttons ? '' : '<div class="nbHero-actions">' +
              '<a class="nbHero-btn nbHero-btn--main" data-play="' + i.Id + '" href="' + url + '">' + icono('play_arrow') + 'Ver ahora</a>' +
              '<a class="nbHero-btn" href="' + url + '">' + icono('info') + 'Más info</a>' +
            '</div>') +
          '</div></article>';
      }).join('') + '</div>' +
      '<button class="nbHero-nav nbHero-prev" aria-label="Anterior">' + icono('chevron_left') + '</button>' +
      '<button class="nbHero-nav nbHero-next" aria-label="Siguiente">' + icono('chevron_right') + '</button>' +
      '<div class="nbHero-dots">' + items.map(function (_, n) { return '<button class="nbHero-dot' + (n === 0 ? ' is-active' : '') + '" data-i="' + n + '" aria-label="Ir a ' + (n + 1) + '"><i></i></button>'; }).join('') + '</div>';

    var actual = 0, timer = null, slides = el.querySelectorAll('.nbHero-slide'), dots = el.querySelectorAll('.nbHero-dot');
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
    el.querySelector('.nbHero-prev').onclick = function () { ir(actual - 1); play(); };
    el.querySelector('.nbHero-next').onclick = function () { ir(actual + 1); play(); };
    Array.prototype.forEach.call(dots, function (d) { d.onclick = function () { ir(+d.dataset.i); play(); }; });
    el.addEventListener('mouseenter', function () { stop(); el.classList.add('is-paused'); });
    el.addEventListener('mouseleave', play);
    var x0 = null;
    el.addEventListener('touchstart', function (e) { x0 = e.touches[0].clientX; }, { passive: true });
    el.addEventListener('touchend', function (e) { if (x0 === null) return; var dx = e.changedTouches[0].clientX - x0; if (Math.abs(dx) > 50) { ir(actual + (dx < 0 ? 1 : -1)); play(); } x0 = null; });
    if (c.play) Array.prototype.forEach.call(el.querySelectorAll('[data-play]'), function (b) { b.addEventListener('click', function () { try { sessionStorage.setItem('nbAutoplay', b.dataset.play); } catch (e) {} }); });
    el.style.setProperty('--nb-int', INTERVALO + 'ms');
    play();
    return el;
  }

  var montando = false;
  function montar() {
    if (!enHome() || !api() || !api().getCurrentUserId || !api().getCurrentUserId()) return;
    var v = vistaHome();
    var cont = v && v.querySelector('.homeSectionsContainer .sections, .tabContent.is-active .sections');
    if (!cont || v.querySelector('.nbHero') || montando) return;
    var c = cfg();
    if (c.count <= 0) return;
    montando = true;
    cargar(c).then(function (items) {
      montando = false;
      if (!items.length || v.querySelector('.nbHero')) return;
      cont.insertBefore(construir(items, c), cont.firstChild);
    }).catch(function (e) { montando = false; console.warn('[NebulaHero]', e); });
  }

  // «Ver ahora»: al llegar a la ficha pulsa su botón de reproducir una sola vez
  function autoplay() {
    var id; try { id = sessionStorage.getItem('nbAutoplay'); } catch (e) { return; }
    if (!id || location.hash.indexOf('id=' + id) < 0) return;
    var b = document.querySelector('.view-item-item:not(.page-hidden) .btnMainPlay:not(.hide), .view-item-item:not(.page-hidden) .btnPlay:not(.hide)');
    if (!b) return;
    try { sessionStorage.removeItem('nbAutoplay'); } catch (e) {}
    setTimeout(function () { b.click(); }, 350);
  }

  // En pantallas estrechas o bajas Emby convierte los menús de audio, subtítulos… en una hoja a pantalla completa (con !important).
  // Se dejan flotando junto al botón que los abrió, como en el ordenador.
  var tocado = null, tocadoEn = 0;
  document.addEventListener('pointerdown', function (e) {
    var b = e.target.closest && e.target.closest('button, select, .selectContainer');
    if (b) { tocado = b.getBoundingClientRect(); tocadoEn = Date.now(); }
  }, true);

  function colocar(d) {
    var s = d.style, ancla = tocado;
    [['bottom', 'auto'], ['right', 'auto'], ['min-height', '0'], ['height', 'auto'], ['width', 'auto'],
     ['max-width', 'calc(100vw - 20px)'], ['max-height', '70vh']].forEach(function (p) { s.setProperty(p[0], p[1], 'important'); });
    var h = d.offsetHeight, w = d.offsetWidth, vh = window.innerHeight, vw = window.innerWidth;
    var top = ancla.bottom + 6 + h <= vh - 8 ? ancla.bottom + 6 : Math.max(8, ancla.top - 6 - h);   // debajo si cabe; si no, encima
    var left = Math.min(Math.max(10, ancla.left), vw - 10 - w);
    s.setProperty('top', top + 'px', 'important');
    s.setProperty('left', Math.max(10, left) + 'px', 'important');
  }

  function menusFlotantes() {
    if (!tocado || Date.now() - tocadoEn > 1500) return;   // sin botón tocado: se queda como hoja
    Array.prototype.forEach.call(document.querySelectorAll('.dialog-fullscreen-lowres:not(.nbPop)'), function (d) {
      if (!d.querySelector(':scope > .actionSheetScroller')) return;
      d.classList.add('nbPop');
      // Emby reescribe el estilo al terminar de abrirlo: se coloca después y otra vez si lo vuelve a tocar
      requestAnimationFrame(function () { colocar(d); });
      var n = 0;
      new MutationObserver(function (m, o) { if (++n > 6) return o.disconnect(); if (!/bottom: auto !important/.test(d.getAttribute('style') || '')) colocar(d); })
        .observe(d, { attributes: true, attributeFilter: ['style'] });
    });
  }

  var pend = false;
  new MutationObserver(function () {
    menusFlotantes();
    if (pend) return; pend = true;
    (document.hidden ? function (f) { setTimeout(f, 50); } : requestAnimationFrame)(function () { pend = false; if (enHome()) montar(); else autoplay(); });
  }).observe(document.documentElement, { childList: true, subtree: true });
  window.addEventListener('hashchange', montar);
})();
