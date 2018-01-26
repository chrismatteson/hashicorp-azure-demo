var express = require('express');
var app = express();
var rp = require('request-promise');
var sql = require('mssql')
var config = require('./config')

//SQL config
var db = {
    user: '',
    password: '',
    server: config.azuresql_server,
    database: config.azuresql_db,
    options: {
        encrypt: true
    }
}

//Routes
app.get('/', function(req, res) {
    var options = {
        uri: config.vault_url + '/v1/azuresql/creds/read',
        headers: {
            'X-Vault-Token': process.env.VAULT_TOKEN
        },
        json: true // Automatically parses the JSON string in the response
    };
    rp(options)
        .then(function(creds) {
            //Creds
            console.log(creds.data.username);
            console.log(creds.data.password);
            db.user = creds.data.username
            db.password = creds.data.password
            //SQL
            sql.connect(db).then(() => {
                return sql.query `select * from hello`
            }).then(result => {
                //Close the connection so we can get new creds every time
                sql.close();
                //Send our result
                res.json({
                    username: creds.data.username,
                    password: creds.data.password,
                    text: result.recordset[0].Text
                });
            }).catch(err => {
                console.log(err)
            })
            sql.on('error', err => {
                console.log(err)
            })
        })
        .catch(function(err) {
            console.log(err)
        });
});

app.listen(3000, function() {
    console.log('Azure SQL app listening on port 3000!');
});
