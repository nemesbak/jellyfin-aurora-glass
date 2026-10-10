/* Aurora Glass — cargador del carrusel para el plugin «JavaScript Injector» (o cualquier inyector).
   Pega estas líneas tal cual: siempre carga la última versión del repo. */
(function () {
  if (document.getElementById('auroraHeroJs')) return;
  var s = document.createElement('script');
  s.id = 'auroraHeroJs'; s.defer = true;
  s.src = 'https://cdn.jsdelivr.net/gh/nemesbak/jellyfin-aurora-glass@main/aurora-home.js';
  document.head.appendChild(s);
})();
