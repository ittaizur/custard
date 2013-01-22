function refresh(force){
  var settings = $('#settings textarea').val()
  if(settings != activeSettings || force == true){
    activeSettings = settings
    $('h1').html(baseUrl + '<span class="hash">#' + encodeURIComponent(settings) + '</span>')
    // We have to completely regenerate the iframe, because
    // iframes don't reload when you only change their URL hash.
    $('iframe').replaceWith('<iframe src="' + baseUrl + '#' + encodeURIComponent(settings) + '"></iframe>')
  }
}

function flashRefreshButton(){
  $('#refresh').addClass('hover')
  setTimeout(function(){
    $('#refresh').removeClass('hover')
  }, 100)
}

function showSettings(){
  $('#settings').show().children('textarea').focus()
}

function hideSettings(){
  $('#settings').hide()
}

function exec(cmd) {
  return $.ajax({
    url: window.boxServer + '/' + window.boxName + '/exec',
    type: 'POST',
    data: {
      apikey: window.user.apiKey,
      cmd: cmd
    }
  })
}

function reinstall(){
  exec("cd; for f in */setup; do $f;done")
  .done(function(settings){
    refresh(true)
  }).fail(function(jqXHR, textStatus, errorThrown){
    alert('Ooops! Something went wrong. See javascript console for details.')
    console.warn(jqXHR.status, jqXHR.statusText, jqXHR.responseText, textStatus, errorThrown)
  })
}

$(function(){
  activeSettings = null

  exec('cd; cat scraperwiki.json')
  .done(function(data){
    settings = JSON.parse(data)
    baseUrl = window.boxServer + '/' + window.boxName + '/' + settings.publish_token + '/http'
    refresh(true)
  }).fail(function(jqXHR, textStatus, errorThrown){
    if(errorThrown == 'Not Found'){
      $('h1').html('<b class="text-error">Error!</b> Box &ldquo;' + window.boxName + '&rdquo; does not exist!')
    } else if(errorThrown == 'Forbidden'){
      $('h1').html('<b class="text-error">Error!</b> Incorrect apikey for accessing box &ldquo;' + window.boxName + '&rdquo;!')
    } else {
      $('h1').html('<b class="text-error">Error!</b> Something went wrong. See javascript console for details.')
    }
    console.warn(jqXHR.status, jqXHR.statusText, jqXHR.responseText, textStatus, errorThrown)
  })

  var obj = {
    source: {
        apikey: window.user.apiKey
    },
    target: {
        url: window.boxServer + '/boxname/publishtoken'
    }
  }
  $('textarea').val(JSON.stringify(obj, null, 2))

  $(document).on('keydown', function(e){
    if( e.which === 82 && e.metaKey ) {
      e.preventDefault()
      refresh(true)
      flashRefreshButton()
      return false
    } else if(e.which === 27 && $('#settings').is(':visible')){
      e.preventDefault()
      $('#settings textarea').blur()
    }
  })

  $('#refresh').on('click', function(){
    refresh(true)
  })

  $('#toggle-settings').on('click', function(e){
    e.preventDefault()
    if(!$('#settings').is(':visible')){
      showSettings()
    }
  })

  $('#settings textarea').on('blur', function(){
    refresh()
    hideSettings()
  })

  $('h1').on('click', '.hash', showSettings)

  $('#reinstall').on('click', reinstall)

})
