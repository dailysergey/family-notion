const title = document.querySelector('title');
if (title) {
  const applyBrand = () => {
    const next = title.textContent.replace(/(^|[·|–—-]\s*)SiYuan(?: v[0-9]+(?:\.[0-9]+)+)?(?=$|\s*[-·|–—])/g, '$1notion');
    if (next !== title.textContent) title.textContent = next;
  };
  new MutationObserver(applyBrand).observe(title, {subtree:true, childList:true, characterData:true});
  applyBrand();
}
