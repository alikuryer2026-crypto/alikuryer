// V12: accessible food-photo fallbacks and category scroll alignment.
(function(){
 const names=['Barchasi','Pitsa','Burger','Lavash','Somsa','Milliy taom','Salat'];
 const emojis=['🍽️','🍕','🍔','🌯','🥟','🍚','🥗'];
 function enhance(){
  const rail=document.getElementById('categories');
  if(!rail)return;
  rail.querySelectorAll('.category').forEach((card,i)=>{
   const img=card.querySelector('img');if(!img)return;
   if(!card.querySelector('.food-fallback')){const span=document.createElement('span');span.className='food-fallback';span.setAttribute('aria-hidden','true');span.textContent=emojis[names.indexOf(card.querySelector('b')?.textContent)]||emojis[i]||'🍽️';img.after(span)}
   if(!img.dataset.fallbackBound){
    img.dataset.fallbackBound='1';
    img.addEventListener('error',()=>card.classList.add('image-failed'));
    img.addEventListener('load',()=>card.classList.remove('image-failed'));
   }
   if(img.complete&&img.naturalWidth===0)card.classList.add('image-failed');
  });
  if(!rail.dataset.initialAligned){rail.scrollLeft=0;rail.dataset.initialAligned='1'}
 }
 document.addEventListener('DOMContentLoaded',()=>{
  const rail=document.getElementById('categories');if(!rail)return;
  enhance();new MutationObserver(enhance).observe(rail,{childList:true});
 });
})();
