#!/usr/bin/env coffee
#
# Finds accounts with a premium plan, but not a linked recurly subscription.

mongoose = require 'mongoose'
async = require 'async'
mongoose.connect process.env.CU_DB

_ = require 'underscore'
plans = require 'plans.json'
{User} = require 'model/user'

CLI = false

main = (TheUser) ->
  paying_plans = _.filter(_.keys(plans), (plan) ->
    return plans[plan]['$']
  )
  # console.log "paying_plans", paying_plans

  TheUser.find { 'accountLevel': { '$in': paying_plans } }, (err, users) ->
    if err?
      console.log err

    async.each users, (user, cb) ->
      user.getCurrentSubscription (err, subscription) ->
        # they're a data services customer
        if user.accountLevel == 'dataservices-ec2'
          return cb null
        # they're paying for their plan
        if subscription?.plan?.plan_code == user.accountLevel
          return cb null
        # scremium is a test account that needs to be on this plan
        if user.shortName == 'scremium'
          return cb null
        # special case users - check these time to time
        # Joel Hacker - on xlarge plan at was promised > 100 datsets back in the day
        # CSV Soundsystem - paid in advance by PayPal for I think 3 years, review again in mid-2015
        if user.shortName == 'joelhacker' or user.shortName == 'csv'
          return cb null

        # something is up
        console.log "user:", user.shortName, user.displayName, user.email, "mongo plan:", user.accountLevel
        if err?
          if /You have no Recurly account/.test(err['error'])
            console.log "    no recurly account"
          else
            console.log "    failed to getCurrentSubscription", err
        else if subscription
          console.log "    subscription:", subscription.plan.plan_code
        else
          console.log "    no subscription"
        cb null
    , (err) ->
      process.exit() if CLI?

if require.main == module
  CLI = true
  process.env.NODE_ENV = 'cron'
  main(User)

exports.main = main

