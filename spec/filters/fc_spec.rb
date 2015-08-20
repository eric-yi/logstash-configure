# encoding: utf-8

require "logstash/devutils/rspec/spec_helper"

unless LogStash::Environment.const_defined?(:LOGSTASH_HOME)
  LogStash::Environment::LOGSTASH_HOME = File.expand_path("../../../", __FILE__)
end

require "logstash/filters/fc"
require "logstash/filters/grok"

describe LogStash::Filters::Fc do

  describe "single line" do
    config <<-'CONFIG'
      filter {
        grok {
          break_on_match => false
          match => { "message" => "\[(?<datetime>\d{2}\d{2}\d{2}\d{2}\d{2}\d{2}\.\d{3}\.\d{3})\](?<tid>\d{5}:\d{7}):(?<mes>.*)" }
        }
        # fc{
        # }
      }
    CONFIG

    sample "[140127154117.208.101]16332:6652288:开始正向交易流程[g_2xxx]..." do
      insist { subject["mes"] } == "开始正向交易流程[g_2xxx]..."
      insist { subject["tid"] } == "16332:6652288"
    end
  end


  describe "multiple lines" do
    config <<-'CONFIG'
      filter {
        grok {
          break_on_match => false
          match => [ "message" , "\[(?<datetime>\d{2}\d{2}\d{2}\d{2}\d{2}\d{2}\.\d{3}\.\d{3})\](?<tid>\d{5}:\d{7}):(?<mes>.*)" ]
        }
        fc{
        }
      }
    CONFIG

    sample [  '[140127154117.208.101]16332:6652288:开始正向交易流程[g_2xxx]...',
              '[140127154117.834.225]16332:6652288:  TR_TYPE[2]=288(3231)',
              '[140127154117.834.717]16332:6652288:  TR_STATUS[1]=2881(30)',
              '[140127154117.204.627]16416:6652287:开始正向交易流程[g_2xxx]...',
              '[140127154117.837.430]16416:6652287:  TR_STATUS[1]=2871(30)',
              '[140127154117.282.336]16400:6652294:开始正向交易流程[g_2xxx]...',
              '[140127154117.838.068]16400:6652294:  TR_STATUS[1]=2941(30)',
              '[140127154117.847.491]16332:6652288:关闭TDA[629]',
              '[140127154117.352.266]16361:6652302:开始正向交易流程[g_2xxx]...',
              '[140127154117.847.277]16361:6652302:  TR_TYPE[2]=302(3231)',
              '[140127154117.838.068]16361:6652302:  TR_STATUS[1]=3021(30)',
              '[140127154117.837.684]16416:6652287:  TR_TYPE[2]=287(3231)',
              '[140127154117.852.403]16416:6652287:关闭TDA[287]' ] do

      puts subject

      insist { subject[0]['tid'] } == '16332:6652288'
      insist { subject[0]['lines'] } == %w(开始正向交易流程[g_2xxx]... \ \ TR_TYPE[2]=288(3231) \ \ TR_STATUS[1]=2881(30) 关闭TDA[629])
      insist { subject[1]['tid'] } == '16416:6652287'
      insist { subject[1]['lines'] } == %w(开始正向交易流程[g_2xxx]... \ \ TR_STATUS[1]=2871(30) \ \ TR_TYPE[2]=287(3231) 关闭TDA[287])
    end
  end

end
