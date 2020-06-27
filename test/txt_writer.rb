require_relative '../boot'


########
# helpers
#   normalize team names
def normalize( matches, league: )
    matches = matches.sort do |l,r|
      ## first by date (older first)
      ## next by matchday (lowwer first)
      res =   l.date <=> r.date
      res =   l.round <=> r.round   if res == 0
      res
    end


    league = SportDb::Import.catalog.leagues.find!( league )
    country = league.country

    ## todo/fix: cache name lookups - why? why not?
    matches.each do |match|
       team1 = SportDb::Import.catalog.clubs.find_by!( name: match.team1,
                                                       country: country )
       team2 = SportDb::Import.catalog.clubs.find_by!( name: match.team2,
                                                       country: country )

       puts "#{match.team1} => #{team1.name}"  if match.team1 != team1.name
       puts "#{match.team2} => #{team2.name}"  if match.team2 != team2.name

       match.update( team1: team1.name )
       match.update( team2: team2.name )
    end
    matches
end





##########
# start

def write_eng( season )
  season = SportDb::Import::Season.new( season )  ## normalize season

  matches = SportDb::CsvMatchParser.read( "../../stage/one/#{season.path}/eng.1.csv" )

  pp matches[0]
  puts "#{matches.size} matches"

  league_name  = 'English Premier League'

  matches = normalize( matches, league: league_name )

  path = "../../../openfootball/england/#{season.path}/1-premierleague.txt"
  SportDb::TxtMatchWriter.write( path, matches,
                               title: "#{league_name} #{season.key}",
                               round: 'Matchday',
                               lang:  'en')
end


def write_es( season )
## todo/fix:
## extras - add more info
## 2018/19
##   Jornada 6 /  Sevilla FC - Real Madrid
##      [André Silva 17', 21' Wissam Ben Yedder 39']

    season = SportDb::Import::Season.new( season )  ## normalize season

    matches = SportDb::CsvMatchParser.read( "../../stage/one/#{season.path}/es.1.csv" )

    pp matches[0]
    puts "#{matches.size} matches"

    league_name  = 'Primera División de España'

    matches = normalize( matches, league: league_name )

    path = "../../../openfootball/espana/#{season.path}/1-liga.txt"
    SportDb::TxtMatchWriter.write( path, matches,
                            title: "#{league_name} #{season.key}",
                            round: 'Jornada',
                            lang:  'es')

end


def write_it( season )
    season = SportDb::Import::Season.new( season )  ## normalize season

    matches = SportDb::CsvMatchParser.read( "../../stage/one/#{season.path}/it.1.csv" )

    pp matches[0]
    puts "#{matches.size} matches"

    league_name  = 'Italian Serie A'

    matches = normalize( matches, league: league_name )

    path = "../../../openfootball/italy/#{season.path}/1-seriea.txt"
    SportDb::TxtMatchWriter.write( path, matches,
                            title: "#{league_name} #{season.key}",
                            round: ->(round) { "%s^ Giornata" % round },
                            lang:  'it')
end


# write_eng( '2018/19' )
# write_eng( '2019/20' )

# write_es( '2019/20' )

write_it( '2019/20' )


puts "bye"