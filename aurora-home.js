/* Aurora Glass — carrusel destacado en la portada de Jellyfin.
   Se carga desde index.html (ver install/inject-docker.sh). Solo lee la API con la sesión del usuario. */
(function () {
  'use strict';
  var N = 8;              // títulos en el carrusel
  var INTERVALO = 8000;   // ms entre diapositivas
  var cache = null, cacheUser = null, cacheAt = 0;

  function api() { return window.ApiClient; }
  function enHome() { if (/[?&]tab=[1-9]/.test(location.hash)) return false; return /^#\/home(\.html)?(\?|$)/.test(location.hash) || location.hash === '' || location.hash === '#/'; }

  function img(id, tipo, extra) {
    return api().getUrl('Items/' + id + '/Images/' + tipo + (extra || ''), { quality: 90, maxWidth: tipo === 'Logo' ? 700 : 1920 });
  }

  function cargar() {
    var a = api(), uid = a.getCurrentUserId();
    if (cache && cacheUser === uid && Date.now() - cacheAt < 10 * 60 * 1000) return Promise.resolve(cache);
    var hace = new Date(Date.now() - 120 * 864e5).toISOString();
    var base = {
      Recursive: true, IncludeItemTypes: 'Movie,Series', ImageTypes: 'Backdrop,Logo',
      Fields: 'Overview,Genres,ProductionYear,CommunityRating,OfficialRating,RunTimeTicks,ChildCount,ImageTags,BackdropImageTags,UserData',
      IsPlayed: false, HasOverview: true, Limit: 40, SortBy: 'DateCreated', SortOrder: 'Descending', MinDateLastSaved: hace
    };
    return a.getJSON(a.getUrl('Users/' + uid + '/Items', base)).then(function (r) {
      var items = (r.Items || []).filter(function (i) {
        return i.BackdropImageTags && i.BackdropImageTags.length && i.ImageTags && i.ImageTags.Logo;
      });
      // mezcla y se queda con N, priorizando nota alta
      items.sort(function (x, y) { return (y.CommunityRating || 0) - (x.CommunityRating || 0) + (Math.random() - .5) * 3; });
      cache = items.slice(0, N); cacheUser = uid; cacheAt = Date.now();
      return cache;
    });
  }

  function dur(t) { if (!t) return ''; var m = Math.round(t / 6e8); return m >= 60 ? Math.floor(m / 60) + ' h ' + (m % 60) + ' min' : m + ' min'; }
  function esc(s) { return String(s || '').replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }

  function construir(items) {
    var sid = api().serverId();
    var el = document.createElement('section');
    el.className = 'agHero';
    el.innerHTML =
      '<div class="agHero-slides">' + items.map(function (i, n) {
        var meta = [i.ProductionYear, i.Type === 'Series' ? (i.ChildCount ? i.ChildCount + (i.ChildCount === 1 ? ' temporada' : ' temporadas') : 'Serie') : dur(i.RunTimeTicks), i.OfficialRating]
          .filter(Boolean).map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('');
        if (i.CommunityRating) meta += '<span class="agHero-star">★ ' + i.CommunityRating.toFixed(1) + '</span>';
        var gen = (i.Genres || []).slice(0, 3).map(function (g) { return '<span class="agHero-chip">' + esc(g) + '</span>'; }).join('');
        var url = '#/details?id=' + i.Id + '&serverId=' + sid;
        return '<article class="agHero-slide' + (n === 0 ? ' is-active' : '') + '" data-i="' + n + '">' +
          '<div class="agHero-bg" style="background-image:url(\'' + img(i.Id, 'Backdrop', '/0') + '\')"></div>' +
          '<div class="agHero-shade"></div>' +
          '<div class="agHero-body">' +
            '<img class="agHero-logo" alt="' + esc(i.Name) + '" src="' + img(i.Id, 'Logo') + '">' +
            '<div class="agHero-meta">' + meta + '</div>' +
            '<div class="agHero-genres">' + gen + '</div>' +
            '<p class="agHero-overview">' + esc(i.Overview) + '</p>' +
            '<div class="agHero-actions">' +
              '<a class="agHero-btn agHero-btn--main" data-play="' + i.Id + '" href="' + url + '"><span class="material-icons">play_arrow</span>Ver ahora</a>' +
              '<a class="agHero-btn" href="' + url + '"><span class="material-icons">info_outline</span>Más info</a>' +
            '</div>' +
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
    function play() { stop(); timer = setInterval(function () { if (!document.hidden && document.body.contains(el)) ir(actual + 1); else if (!document.body.contains(el)) stop(); }, INTERVALO); el.classList.remove('is-paused'); }
    function stop() { if (timer) clearInterval(timer); timer = null; }
    el.querySelector('.agHero-prev').onclick = function () { ir(actual - 1); play(); };
    el.querySelector('.agHero-next').onclick = function () { ir(actual + 1); play(); };
    dots.forEach(function (d) { d.onclick = function () { ir(+d.dataset.i); play(); }; });
    el.addEventListener('mouseenter', function () { stop(); el.classList.add('is-paused'); });
    el.addEventListener('mouseleave', play);
    var x0 = null;
    el.addEventListener('touchstart', function (e) { x0 = e.touches[0].clientX; }, { passive: true });
    el.addEventListener('touchend', function (e) { if (x0 === null) return; var dx = e.changedTouches[0].clientX - x0; if (Math.abs(dx) > 50) { ir(actual + (dx < 0 ? 1 : -1)); play(); } x0 = null; });
    el.querySelectorAll('[data-play]').forEach(function (b) { b.addEventListener('click', function () { try { sessionStorage.setItem('agAutoplay', b.dataset.play); } catch (e) {} }); });
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
    montando = true;
    cargar().then(function (items) {
      montando = false;
      if (items.length < 2 || page.querySelector('.agHero')) return;
      cont.parentNode.insertBefore(construir(items), cont);
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

  var pend = false;
  new MutationObserver(function () {
    if (pend) return; pend = true;
    requestAnimationFrame(function () { pend = false; cssPanel(); if (enHome()) montar(); else autoplay(); });
  }).observe(document.documentElement, { childList: true, subtree: true });
  window.addEventListener('hashchange', montar);
})();
