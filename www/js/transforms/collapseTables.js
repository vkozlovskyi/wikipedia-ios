const tableCollapser = require('wikimedia-page-library').CollapseTable
var location = require('../elementLocation')

function footerDivClickCallback(container) {
  if(location.isElementTopOnscreen(container)){
    window.scrollTo( 0, container.offsetTop - 10 )
  }
}

function adjustTables(content, isMainPage, isInitiallyHidden, pageTitle, infoboxTitle, otherTitle, footerTitle) {
  tableCollapser.adjustTables(window, content, pageTitle, isMainPage, isInitiallyHidden, infoboxTitle, otherTitle, footerTitle, footerDivClickCallback)

  // Prevents some collapsed tables from scrolling side-to-side.
  // May want to move this to wikimedia-page-library if there are no issues.
  Array.from(document.querySelectorAll('.app_table_container *[class~="nowrap"]'))
    .forEach(function(el) {el.classList.remove('nowrap')})
}

exports.adjustTables = adjustTables