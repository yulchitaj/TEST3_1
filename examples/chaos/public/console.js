var PUB_KEY = "demo-36";
var SUB_KEY = "demo-36";
var SECRET_KEY = "demo";

var deviceUUID = "ChaosAdmin"

var activeChannels = [];
var tempActiveChannels = [];

function log(msg) {
    $("#log").html($("#log").html() + "<br />" + msg);
}

function deviceError(data) {
    log("Encountered Error: " + data);
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
    formList.push("chaos_admin");

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

function getConfig(){
    pubnub.publish({
        "channel" : "chaos_admin",
        "message" : {"type":"admin", "run_mode":{"get":"true"}},
        "callback" : function(m, e, c){
            console.log("m: " + m)
        },
        "error" : function(m, e, c){
            console.log("m: " + m)
        }
    });
}

function subscribeLocal(ch) {
    pubnub.subscribe({
        "channel": ch,
        "callback": function (m, e, c) {
            console.log("Received: " + m);
            if ($("#subOutputTextarea").html().length > 10000) {
                $("#subOutputTextarea").html("");
            }
            $("#subOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[" + c + "] " + JSON.stringify(m) + "\r\n" + $("#subOutputTextarea").html());

        },
        "connect": function (channel) {
            activeChannels.push(channel);
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[connect] " + JSON.stringify(channel) + "\r\n" + $("#errorOutputTextarea").html());
            updateSubscribeUI();
        },
        "error": function(er){
            $("#errorOutputTextarea").html(moment().format('MM-D-YY hh:mm:ss') + ":[error] " + JSON.stringify(er) + "\r\n" + $("#errorOutputTextarea").html());
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
}

function updateSubscribeUI(){
    $("#subChannelsLabel").html("Subscribed to: " + JSON.stringify(activeChannels));
    console.log("active after: " + JSON.stringify(activeChannels));
}