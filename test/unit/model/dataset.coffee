sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/app.coffee'

describe 'Client model: Dataset', ->
  describe 'URL', ->
    beforeEach ->
      @boxName = 'blah'
      obj = {user: 'test', box: @boxName}
      @dataset = Cu.Model.Dataset.findOrCreate obj

    it 'has an URL of /api/test/datasets/{id} if the dataset is new', ->
      @dataset.new = true
      @dataset.url().should.equal '/api/test/datasets'

    it 'has an URL of /api/test/datasets if the dataset is not new', ->
      @dataset.new = false # We shouldn't have to set this...
      @dataset.url().should.include @boxName

describe 'Server model: Dataset', ->
  Dataset = require('model/dataset')()

  before ->
    @dataset = new Dataset()

  it 'has a save method', ->
    should.exist @dataset.save

