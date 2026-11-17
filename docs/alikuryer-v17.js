/* V17: connect interactive UI controls to their existing local flows. */
(function(){
 const $=id=>document.getElementById(id);
 function refreshStats(){
  const orders=$('profileorders'),fav=$('profilefavorites');
  if(orders)orders.textContent=Array.isArray(data.orders)?data.orders.length:0;
  if(fav)fav.textContent=Array.isArray(data.favorites)?data.favorites.length:0;
 }
 function profilePhoto(){
  const avatar=document.querySelector('#profile .avatar');if(!avatar)return;
  let photo='';try{photo=localStorage.getItem('alikuryer-profile-photo')||''}catch(e){}
  if(photo){avatar.textContent='';avatar.style.backgroundImage='url('+JSON.stringify(photo)+')';avatar.style.backgroundSize='cover';avatar.style.backgroundPosition='center'}
  if($('ak-v17-upload'))return;
  const label=document.createElement('label');label.className='ak-v17-profile-upload';label.id='ak-v17-upload';label.textContent='📷 Profil rasmini tanlash ';
  const input=document.createElement('input');input.type='file';input.accept='image/png,image/jpeg,image/webp';input.setAttribute('aria-label','Profil rasmini yuklash');
  input.addEventListener('change',()=>{const f=input.files?.[0];if(!f)return;if(f.size>2*1024*1024){toast('Rasm 2 MB dan kichik bo‘lsin');return}
   const reader=new FileReader();reader.onload=()=>{try{localStorage.setItem('alikuryer-profile-photo',reader.result)}catch(e){toast('Rasmni saqlash uchun xotira yetarli emas');return}avatar.textContent='';avatar.style.backgroundImage='url('+JSON.stringify(reader.result)+')';avatar.style.backgroundSize='cover';avatar.style.backgroundPosition='center';toast('Profil rasmi saqlandi')};reader.readAsDataURL(f)});
  label.append(input);avatar.closest('.profilehero')?.after(label);
 }
 function profileActions(){
  const profile=$('profile');if(!profile||$('ak-v17-actions'))return;
  const actions=document.createElement('div');actions.id='ak-v17-actions';actions.className='ak-v17-actions';
  const map=document.createElement('button');map.type='button';map.textContent='📍 Manzilni xaritadan tanlash';map.onclick=()=>openMapModal(false);
  const orders=document.createElement('button');orders.type='button';orders.textContent='📦 Buyurtmalarim';orders.onclick=()=>show('orders');
  actions.append(map,orders);profile.querySelector('.profile-card')?.after(actions);
 }
 function updateCartButton(){
  const btn=document.querySelector('#cart button[onclick="checkout()"]');
  if(btn){btn.disabled=!(typeof count==='function'&&count()>0);btn.style.opacity=btn.disabled?'.55':'1'}
 }
 function fixHeader(){
  const bell=document.querySelector('header .iconbtn');if(bell){bell.title='Buyurtmalarim';bell.setAttribute('aria-label','Buyurtmalarim')}
  const cart=document.querySelector('header .carttop');if(cart)cart.setAttribute('aria-label','Savatchani ochish');
 }
 function notifyInactive(){
  document.querySelectorAll('#profile .option').forEach(option=>{
   if(option.textContent.includes('To‘lov usullari')){option.title='Onlayn to‘lov hali ulanmagan';option.style.cursor='default'}
   if(option.textContent.includes('Til:')){option.title='Xitoycha tarjima hali to‘liq ulanmagan';option.style.cursor='default'}
  });
 }
 function refresh(){refreshStats();profilePhoto();profileActions();updateCartButton();fixHeader();notifyInactive()}
 document.addEventListener('DOMContentLoaded',()=>{
  refresh();
  if(typeof drawCart==='function'){const base=drawCart;drawCart=function(){base();updateCartButton();refreshStats()}}
  if(typeof drawOrders==='function'){const base=drawOrders;drawOrders=function(){base();refreshStats()}}
  if(typeof drawProfile==='function'){const base=drawProfile;drawProfile=function(){base();refreshStats();profilePhoto()}}
  if(typeof show==='function'){const base=show;show=function(v){base(v);refresh()}}
 });
})();