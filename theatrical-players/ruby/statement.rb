require 'json'
def parse(file)
  json = File.read(file)
  object = JSON.parse(json, object_class: OpenStruct)
end

invoices = parse('../invoices.json')
plays = parse('../plays.json')

def statement(invoice, plays)
    totalAmount = 0
    volumeCredits = 0
    result = "Statement for #{invoice.customer}\n\t"


    invoice.performances.each do |perf|
      play = plays[perf.playID]
      thisAmount = 0
      case play.type
      when "tragedy"
        thisAmount = 40000
        if (perf.audience > 30)
          thisAmount += 1000 * (perf.audience - 30)
        end
      when "comedy"
        thisAmount = 30000
        if (perf.audience > 20)
          thisAmount += 10000 + 500 * (perf.audience - 20)
        end
        thisAmount += 300 * perf.audience
      else
        raise "unknown type: #{play.type}"
      end
      # add volume credits
      volumeCredits += [perf.audience - 30, 0].max
      # add extra credit for every ten comedy attendees
      volumeCredits += (perf.audience / 5.0).floor if "comedy" === play.type
      # print line for this order
      result += "#{play.name}: #{thisAmount / 100.0} (#{perf.audience} seats)\n\t"
      totalAmount += thisAmount
    end
    result += "Amount owed is #{(totalAmount / 100.0)}\n"
    result += "You earned #{volumeCredits} credits\n"
    result
end

puts statement(invoices[0], plays)
