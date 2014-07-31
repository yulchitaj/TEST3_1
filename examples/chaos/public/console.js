var PUB_KEY = "demo-36";
var SUB_KEY = "demo-36";
var SECRET_KEY = "demo";

var deviceUUID = "ChaosAdmin"

var activeChannels = [];
var tempActiveChannels = [];

function log(msg) {
    $("#log").html($("#log").html() + "<br />" + msg);
}

function pnInit() {

    pubnub = PUBNUB.init({
        "subscribe_key": SUB_KEY,
        "publish_key": PUB_KEY,
        "uuid": deviceUUID
    });
}

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return a.indexOf(i) < 0;});
};

function subscribeFromInput(){
    var formList =  $("#subChannels").val().split(",");

    tempActiveChannels = [];

    formList.forEach(function(c){
        tempActiveChannels.push(c);
    });

    console.log("active before: " + JSON.stringify(activeChannels));
//    console.log("diff1 is: " + JSON.stringify(diff1));
//    console.log("diff2 is: " + JSON.stringify(diff2));
    if (activeChannels.length) {
        pubnub.unsubscribe({"channel":activeChannels});
    }

    if (formList.length) {
        subscribeProxy(formList);
    }

}

function subscribeLocal(ch) {

    pubnub.subscribe({
        "channel": ch,
        "callback": function (m, e, c) {
            console.log("Received: " + m);
            if ($("#subOutputTextarea").html().length > 10000) {
                $("#subOutputTextarea").html("");
            }
            if (ch == "chaos_admin") {
                $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[" + c + "] " + JSON.stringify(m, null, "\t") + "\r\n\r\n" + $("#errorOutputTextarea").html());
            } else {
                $("#subOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[" + c + "] " + JSON.stringify(m) + "\r\n\r\n" + $("#subOutputTextarea").html());
            }

        },
        "connect": function (channel) {
            activeChannels.push(channel);
            updateSubscribeUI();

            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[connect] " + JSON.stringify(channel) + "\r\n\r\n" + $("#errorOutputTextarea").html());

        },
        "error": function(er){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[error] " + JSON.stringify(er) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        }
    });


}
function subscribeProxy(ch) {

    activeChannels = [];

    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "output":"sub", "to":{"ch": ch}},
        "callback" : function(m, e, c){
            console.log("m: " + m)
        },
        "error" : function(m, e, c){
            console.log("m: " + m)
        }
    });

    subscribeLocal(ch);
    subscribeLocal("chaos_admin");

}

function updateSubscribeUI(){
    $("#subChannelsLabel").html("Subscribed to: " + JSON.stringify(activeChannels));
    console.log("active after: " + JSON.stringify(activeChannels));
}


//  Operations

function subTo(ch){

    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "output":"sub", "to":{"ch":ch}},
        "callback" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigSuccess] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        },
        "error" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigError] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        }
    });
}

function getConfig(){

    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "run_mode":{"get":"true"}},
        "callback" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigSuccess] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        },
        "error" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigError] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        }
    });
}

function enableCORS(){
    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "run_mode":"set", "mode":"cors_headers", "value":true},
        "callback" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigSuccess] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        },
        "error" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigError] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        }
    });
}

function disableCORS(){
    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "run_mode":"set", "mode":"cors_headers", "value":false},
        "callback" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigSuccess] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        },
        "error" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigError] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        }
    });
}

function setStatusTo(status, service){
    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "run_mode":"set", "mode":"http_status", "service": service, "value":status},
        "callback" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigSuccess] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        },
        "error" : function(m, e, c){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[getConfigError] " + JSON.stringify(m) + "\r\n\r\n" + $("#errorOutputTextarea").html());
        }
    });
}