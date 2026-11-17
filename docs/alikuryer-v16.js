/* V16: unify icons, clear illustrative promotion labels, enhance storefront. */
(function(){
 const $=id=>document.getElementById(id);
 function improve(){
  const icons={home:'⌂',restaurants:'▦',orders:'▤',cart:'🛒',profile:'♙'};
  document.querySelectorAll('.bottom button[data-v]').forEach(btn=>{const b=btn.querySelector('b');if(b&&icons[btn.dataset.v])b.textContent=icons[btn.dataset.v];btn.setAttribute('aria-label',btn.textContent.trim())});
  document.querySelectorAll('#home .promo').forEach(p=>{const h=p.querySelector('h3'),strong=p.querySelector('strong'),desc=p.querySelector('p');if(!h||!strong)return;
    if(h.textContent.includes('Pitsa')){h.textContent='Pitsa tanlang';strong.textContent='🍕';if(desc)desc.textContent='Menyudagi pitsalarni ko‘ring'}
    if(h.textContent.includes('Burger')){h.textContent='Burgerlar';strong.textContent='🍔';if(desc)desc.textContent='Mazali burgerlarni tanlang'}
  });
  const storefront=$('ak-v15-restaurant');
  if(storefront&&!$('ak-v16-note')){const note=document.createElement('div');note.id='ak-v16-note';note.className='ak-v16-note';note.innerHTML='<span>ℹ️</span><span><strong>Menyu namunasi.</strong> Restoran, narx va yetkazish vaqti haqiqiy hamkorlar ulangach yangilanadi.</span>';storefront.querySelector('.ak-v15-content')?.prepend(note)}
  const float=$('ak-cart-float');if(float&&typeof count==='function'){const visible=!!count()&&($('home')?.classList.contains('active')||storefront?.classList.contains('active'));float.hidden=!visible}
 }
 document.addEventListener('DOMContentLoaded',()=>{
  improve();
  if(typeof show==='function'){const old=show;show=function(v){old(v);improve()}}
  const promos=document.querySelector('#home .promos');if(promos)new MutationObserver(improve).observe(promos,{childList:true});
 });
})();