/* V15: customer restaurant view and cart drawer; sample catalog remains local-only. */
(function(){
 const el=id=>document.getElementById(id);
 const safe=s=>typeof escapeHtml==='function'?escapeHtml(s):String(s);
 let selectedRestaurant='',selectedCategory='Barchasi',productQty=1;
 function init(){
  const root=document.querySelector('.wrap');if(!root||el('ak-v15-restaurant'))return;
  const view=document.createElement('section');view.id='ak-v15-restaurant';view.className='view ak-v15-restaurant';
  view.innerHTML='<div class="ak-v15-banner"><img id="ak-v15-cover" alt="Restoran rasmi"><button type="button" id="ak-v15-back">← Restoranlar</button></div><div class="ak-v15-info"><h1 id="ak-v15-name"></h1><p>Taomlarni tanlang va savatchaga qo‘shing</p><div class="ak-v15-tags"><span id="ak-v15-time"></span><span>🛵 Yetkazish buyurtmada hisoblanadi</span><span>Namuna menyu</span></div></div><div class="ak-v15-content"><h2>Menyu</h2><div id="ak-v15-tabs" class="ak-v15-tabs"></div><div id="ak-v15-grid" class="ak-v15-grid"></div></div>';
  root.append(view);
  el('ak-v15-back').addEventListener('click',()=>show('restaurants'));
  const drawer=document.createElement('div');drawer.id='ak-v15-drawer';drawer.className='ak-v15-drawer';drawer.hidden=true;drawer.innerHTML='<div class="ak-v15-drawer-inner" role="dialog" aria-modal="true" aria-label="Savatcha"><div class="ak-v15-drawer-head"><h2>🛒 Savatcha</h2><button type="button" id="ak-v15-close">✕</button></div><div id="ak-v15-items"></div><div class="ak-v15-drawer-total"><span>Jami</span><span id="ak-v15-total"></span></div><div class="ak-v15-drawer-actions"><button type="button" class="secondary" id="ak-v15-continue">Davom etish</button><button type="button" class="primary" id="ak-v15-checkout">Buyurtmaga o‘tish</button></div></div>';
  document.body.append(drawer);
  el('ak-v15-close').onclick=closeDrawer;el('ak-v15-continue').onclick=closeDrawer;
  el('ak-v15-checkout').onclick=()=>{closeDrawer();show('cart')};
  drawer.addEventListener('click',e=>{if(e.target===drawer)closeDrawer()});
  document.addEventListener('keydown',e=>{if(e.key==='Escape')closeDrawer()});
  document.addEventListener('click',e=>{const float=e.target.closest('#ak-cart-float');if(float){e.stopImmediatePropagation();e.preventDefault();openDrawer()}},true);
  const oldShow=show;show=function(v){oldShow(v);if(v==='ak-v15-restaurant'){document.querySelectorAll('.view').forEach(node=>node.classList.toggle('active',node.id===v));document.querySelectorAll('.bottom button').forEach(b=>b.classList.toggle('active',b.dataset.v==='restaurants'));window.scrollTo(0,0)}};
  chooseRestaurant=function(n){selectedRestaurant=n;selectedCategory='Barchasi';renderRestaurant();show('ak-v15-restaurant')};
  details=function(id){const f=foods.find(x=>x.id===id);if(!f)return;productQty=1;openModal('<div class="ak-v15-sheet"><img class="ak-v15-product-image" src="'+photos[f.img]+'" alt="'+safe(f.n)+'"><h2>'+safe(f.n)+'</h2><p>🏪 '+safe(f.r)+'</p><p>Tarkib va porsiya tafsilotlari restoran tomonidan tasdiqlangach ko‘rsatiladi.</p><div class="ak-v15-qty"><button type="button" onclick="akV15Qty(-1)" aria-label="Kamaytirish">−</button><strong id="ak-v15-product-qty">1</strong><button type="button" onclick="akV15Qty(1)" aria-label="Ko‘paytirish">+</button></div><button class="primary" type="button" onclick="akV15Add('+id+')">Savatchaga qo‘shish · <span id="ak-v15-product-total">'+money(f.p)+'</span></button></div>');window.akV15Qty=function(n){productQty=Math.max(1,Math.min(99,productQty+n));el('ak-v15-product-qty').textContent=productQty;el('ak-v15-product-total').textContent=money(f.p*productQty)};window.akV15Add=function(fid){for(let i=0;i<productQty;i++)add(fid);closeModal();if(typeof floatingCart==='function')floatingCart()}};
  window.akV15OpenDrawer=openDrawer;
 }
 function renderRestaurant(){
  const r=restaurants.find(x=>x.n===selectedRestaurant);if(!r)return;
  el('ak-v15-name').textContent=r.n;el('ak-v15-cover').src=photos[r.img];el('ak-v15-cover').alt=r.n;el('ak-v15-time').textContent='⏱️ Taxminiy '+r.time;
  const list=foods.filter(f=>f.r===r.n);const cats=['Barchasi',...new Set(list.map(f=>f.c))];
  el('ak-v15-tabs').innerHTML=cats.map(c=>'<button type="button" class="'+(selectedCategory===c?'active':'')+'" data-cat="'+safe(c)+'">'+safe(c)+'</button>').join('');
  el('ak-v15-tabs').querySelectorAll('button').forEach(b=>b.onclick=()=>{selectedCategory=b.dataset.cat;renderRestaurant()});
  const shown=list.filter(f=>selectedCategory==='Barchasi'||f.c===selectedCategory);
  el('ak-v15-grid').innerHTML=shown.map(f=>'<article class="ak-v15-food"><img src="'+photos[f.img]+'" alt="'+safe(f.n)+'" loading="lazy"><div class="ak-v15-food-info"><h3>'+safe(f.n)+'</h3><p>'+safe(f.c)+'</p><div class="ak-v15-food-foot"><b>'+money(f.p)+'</b><button type="button" data-id="'+f.id+'">+ Qo‘shish</button></div></div></article>').join('');
  el('ak-v15-grid').querySelectorAll('button[data-id]').forEach(b=>b.onclick=()=>details(Number(b.dataset.id)));
 }
 function openDrawer(){
  const drawer=el('ak-v15-drawer');if(!drawer)return;const entries=Object.entries(data.cart).filter(([id,n])=>n>0&&foods.some(f=>f.id==id));
  el('ak-v15-items').innerHTML=entries.length?entries.map(([id,n])=>{const f=foods.find(x=>x.id==id);return '<div class="itemrow"><img src="'+photos[f.img]+'" alt="'+safe(f.n)+'"><div class="grow"><b>'+safe(f.n)+'</b><div class="muted">'+money(f.p)+'</div></div><div class="qty"><button type="button" data-id="'+id+'" data-delta="-1">−</button><b>'+n+'</b><button type="button" data-id="'+id+'" data-delta="1">+</button></div></div>'}).join(''):'<p class="ak-empty">Savatcha bo‘sh. Taom tanlang.</p>';
  el('ak-v15-items').querySelectorAll('button[data-id]').forEach(b=>b.onclick=()=>{change(Number(b.dataset.id),Number(b.dataset.delta));openDrawer()});
  el('ak-v15-total').textContent=money(subtotal()+(entries.length?12000:0));el('ak-v15-checkout').disabled=!entries.length;drawer.hidden=false;document.body.style.overflow='hidden';
 }
 function closeDrawer(){const d=el('ak-v15-drawer');if(d)d.hidden=true;document.body.style.overflow=''}
 document.addEventListener('DOMContentLoaded',init);
})();