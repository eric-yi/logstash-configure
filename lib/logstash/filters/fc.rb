# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/environment"
require "set"

class LogStash::Filters::Fc < LogStash::Filters::Base

  config_name "fc"
  milestone 3

  @@patterns_path = Set.new
  # @@patterns_path += [LogStash::Environment.pattern_path("*")]

  public
  def initialize(config = {})
    super

    @threadsafe = false

    @types = Hash.new { |h,k| h[k] = [] }
    @pending = Hash.new

    @startNum = 0
    @endNum = 0

  end 

  public
  def register
    require "grok-pure"


    @logger.debug("Registered multiline plugin", :type => @type, :config => @config)
  end 

  public
  def filter(event)
    return unless filter?(event)

    tmp = event.to_hash
    datetime = tmp['datetime']

    if tmp['datetime']==nil || tmp['mes']==nil
      event.cancel
      return
    end

    if !@pending[tmp['tid']] && tmp['mes'] !~ /开始正向交易流程/ then
      event.cancel
      return
    end

    if tmp['mes'] =~ /开始正向交易流程/
      @pending[tmp['tid']] = {}
      @pending[tmp['tid']]['tradecode'] = tmp['tid']
      @pending[tmp['tid']]['time_start'] = Time.new(2000+datetime[0,2].to_i,datetime[2,2].to_i,datetime[4,2].to_i,datetime[6,2].to_i,datetime[8,2].to_i,datetime[10,2].to_i)+datetime[13,3].to_f/1000 + datetime[17,3].to_f/1000000
      @pending[tmp['tid']]['lines'] = []

      @startNum += 1

      puts "---------------" + @startNum.to_s + "---------------"

    end

    if tmp['mes'] =~ /关闭TDA/
      # @logger.debug("Registered multiline plugin", :type => @type, :config => @config)
      @pending[tmp['tid']]['time_end'] = Time.new(2000+datetime[0,2].to_i,datetime[2,2].to_i,datetime[4,2].to_i,datetime[6,2].to_i,datetime[8,2].to_i,datetime[10,2].to_i)+datetime[13,3].to_f/1000 + datetime[17,3].to_f/1000000
      @pending[tmp['tid']]['lines'] << (tmp['mes'])
      tmp.merge!(@pending[tmp['tid']])
      event_new = LogStash::Event.new(tmp)
      event.overwrite(event_new)
      @pending.delete(tmp['tid'])

      @endNum += 1

      puts "***************" + @endNum.to_s + "***************"

    end

    if tmp['mes'] =~ /TR_STATUS/
      @pending[tmp['tid']]['status'] = tmp['mes'].match(/=(.+?)\(/)[1]
    end

    if tmp['mes'] =~ /TR_TYPE/
      @pending[tmp['tid']]['type'] = tmp['mes'].match(/=(.+?)\(/)[1]
    end

    if @pending[tmp['tid']] then
      @pending[tmp['tid']]['lines'] << (tmp['mes'])
      event.cancel
    end

  end
end 

