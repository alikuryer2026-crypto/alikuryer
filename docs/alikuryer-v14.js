/* V14: progressive UI improvements. Keeps existing local-only order safety. */
(function(){
 const $=id=>document.getElementById(id);
 const moneySafe=n=>typeof money==='function'?money(n):String(n);
 let priceFilter='all';
 function addressBar(){
  const home=$('home');const search=home?.querySelector('.searchbox');if(!home||!search)return;
  if(!$('ak-address')){const el=document.createElement('div');el.id='ak-address';el.className='ak-address';el.innerHTML='<div class="ak-address-copy"><small>📍 Yetkazish manzili</small><strong id="ak-address-value">Buyurtmada manzilni tanlang</strong></div><button type="button" id="ak-change-address">O‘zgartirish</button>';search.before(el);$('ak-change-address').addEventListener('click',()=>{if(typeof openMapModal==='function')openMapModal(false)})}
  const addr=typeof data!=='undefined'?data.profile?.address:'';$('ak-address-value').textContent=addr||'Manzilni tanlang';
 }
 function filters(){
  const home=$('home'),search=home?.querySelector('.searchbox');if(!search||$('ak-filter'))return;
  const rail=document.createElement('div');rail.id='ak-filter';rail.className='ak-filter';rail.setAttribute('aria-label','Narx bo‘yicha filtr');
  [['all','Barcha narxlar'],['low','50 000 so‘mgacha'],['mid','50–100 ming'],['high','100 mingdan yuqori']].forEach(([v,label])=>{const b=document.createElement('button');b.type='button';b.textContent=label;b.dataset.price=v;b.setAttribute('aria-pressed',String(v===priceFilter));b.addEventListener('click',()=>{priceFilter=v;rail.querySelectorAll('button').forEach(x=>x.setAttribute('aria-pressed',String(x.dataset.price===v)));applyPriceFilter()});rail.append(b)});search.after(rail);
 }
 function applyPriceFilter(){
  const grid=$('foodgrid');if(!grid||typeof foods==='undefined')return;
  grid.querySelectorAll('article.card').forEach(card=>{const title=card.querySelector('h3')?.textContent;const item=foods.find(f=>f.n===title);const p=item?.p;const ok=priceFilter==='all'||(Number.isFinite(p)&&(priceFilter==='low'?p<=50000:priceFilter==='mid'?p>50000&&p<=100000:p>100000));card.hidden=!ok;card.style.display=ok?'':'none'});
  let empty=$('ak-price-empty');if(!empty){empty=document.createElement('p');empty.id='ak-price-empty';empty.className='ak-empty';empty.textContent='Bu narxda taom topilmadi. Boshqa narxni tanlang.';grid.after(empty)}
  empty.hidden=!!grid.querySelector('article.card:not([hidden])');
 }
 function floatingCart(){
  if(!$('ak-cart-float')){const b=document.createElement('button');b.id='ak-cart-float';b.className='ak-cart-float';b.type='button';b.addEventListener('click',()=>typeof show==='function'&&show('cart'));document.body.append(b)}
  const b=$('ak-cart-float'),n=typeof count==='function'?count():0,home=$('home')?.classList.contains('active');b.hidden=!n||!home;
  if(n)b.innerHTML='<span>🛒 Savatcha · '+n+' ta</span><span>'+moneySafe(typeof subtotal==='function'?subtotal():0)+' ›</span>';
 }
 function refresh(){addressBar();filters();applyPriceFilter();floatingCart()}
 document.addEventListener('DOMContentLoaded',()=>{
  refresh();
  if(typeof render==='function'){const old=render;render=function(){old();refresh()}}
  if(typeof drawCart==='function'){const old=drawCart;drawCart=function(){old();floatingCart()}}
  if(typeof show==='function'){const old=show;show=function(v){old(v);floatingCart();if(v==='home')refresh()}}
  if(typeof updateAddress==='function'){const old=updateAddress;updateAddress=function(){old();addressBar()}}
  const grid=$('foodgrid');if(grid)new MutationObserver(()=>{applyPriceFilter();floatingCart()}).observe(grid,{childList:true});
 });
})();