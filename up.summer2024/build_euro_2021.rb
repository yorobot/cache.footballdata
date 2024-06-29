require_relative 'helper'



SportDb.open_mem   ## use (setup) in memory db

SportDb.read( '../../../openfootball/euro/2020--europe/euro.txt' ) 


puts "table stats:"
SportDb.tables


##
## generate json

SportDb::Model::Event.order( :id ).each do |event|
    puts "    #{event.key} | #{event.league.key} - #{event.league.name} | #{event.season.key}"
end


SportDb::JsonExporter.export_euro( 'euro', out_root: './tmp/json/euro' )


### copy to euro.json repo

require 'fileutils'

src  = './tmp/json/euro/2021/euro.json'
dest = '/sports/openfootball/euro.json/2020/euro.json' 
FileUtils.cp( src, dest )


puts "bye"

