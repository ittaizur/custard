class Cu.View.Pricing extends Backbone.View
  className: 'pricing'

  events:
    'click .upgrade': 'upgradeClick'

  render: ->
    @el.innerHTML = JST['pricing'] upgrade: @options.upgrade
    if @options.upgrade and window.user.effective?.accountLevel
      @$el.find(".account-#{window.user.effective.accountLevel}").prev().addClass('glowing')
    @

  upgradeClick: (e) ->
    e.preventDefault()
    humanPlan = $(e.target).attr('data-plan')
    truePlan = app.truePlan humanPlan
    if window.user.effective?.accountLevel is 'free'
      window.app.navigate "/subscribe/#{truePlan}", {trigger: true}
    else
      # show modal!!
      html = JST['modal-upgrade'] {plan: humanPlan}
      modalWindow = $("""<div class="modal hide fade text-center" style="width: 300px; margin-left: -150px;">#{html}</div>""")
      modalWindow.modal()
      modalWindow.on 'hidden', -> modalWindow.remove()
      modalWindow.on 'click', '.btn-primary', (e) ->
        $(e.target).addClass('loading').html('Upgrading&hellip;')
      # then renew their plan to truePlan magically
      # and reload the page
