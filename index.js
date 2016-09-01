/* Uncle Ike's 0.1
Author: Chris Caruso
September 2016

Skill to query crawler-collected Uncle Ike's daily specials and report them to the user.

*/
var alexa = require('alexa-app');
var mysql = require('mysql');
var iniparser = require('iniparser')
var config = iniparser.parseSync('db.ini')

con = mysql.createConnection({
    host        : config.host,
    user        : config.user,
    password    : config.password,
    database    : config.database
});

con.connect(function(err) {
	if(err){
		console.log("Can't connect! Check your settings.");
		return;
	}
	console.log("Connection established.");

});

var app = new alexa.app('uncleikes');

app.launch(function(request,response) {
  response.session ('open_session', 'true');
    response.say("Welcome to Uncle Ike's Daily Specials.");
    response.shouldEndSession (false, "If you would like to leave, just say exit.");
});

app.intent('specialIntent',
  {
    "utterances": [ "{what is|what's|what's|i want|give me} {the|on} {daily|today's} {deal|special}"]
  },
  function(req,res) {
    con = mysql.createConnection({
      host        : config.host,
      user        : config.user,
      password    : config.password,
      database    : config.database
    });

    con.connect(function(err) {
      if(err){
        console.log("Can't connect! Check your settings.");
        return;
      }
      console.log("Connection established.");
    });
    var sql = 'select name from specials';
    con.query(sql, function (err, rows){
      if(err) callback(err);
      var item_list=[];

      if(rows.length == 0) {
      	res.say("Sorry, I couldn't find any specials.").send();
      	res.shouldEndSession(true);
      	return false;
      }
      else{
	      for (var i in rows) {
	        item_list.push(rows[i].name);
	        console.log("Item:", rows[i].name);
	      }
	    }
      
	    specials = item_list.toString();
	    res.say("The following strains are on special today. " + specials).send();
	    res.shouldEndSession(true);
    });
    return false;
  }
);

app.intent('HelpIntent',
  {
    "slots" : {},
    "utterances": [
      "help"
    ]
  },
  function(req,res){
    res.say("Uncle Ike's has the best deals! Ask me what the daily specials are.");
    res.shouldEndSession(false);
  }
);

app.intent('StopIntent', 
	{
    	"slots" : {},
    	"utterances": [
      		"stop",
      		"cancel",
      		"abort"
    	]
  	},
  	function(req,res) {
		res.shouldEndSession(true);
	}
);

exports.handler = app.lambda();

if ((process.argv.length === 3) && (process.argv[2] === 'schema')){
  console.log (app.schema ());
  console.log (app.utterances ());
}

con.end(function(err) {
	//Ends gracefully
});
