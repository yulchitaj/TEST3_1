var PUB_KEY = "demo";
var SUB_KEY = "demo";
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

    subscribe(formList);
}

function subscribe(ch) {

    activeChannels = [];

    pubnub.subscribe({
        "channel" : ch,
        "callback": function(m,e,c) {
            console.log("Received: " + m);
        },
        "connect": function (channel) {
            activeChannels.push(channel);
            updateSubscribeUI();
        },
        "error" : deviceError
    });
}

function updateSubscribeUI(){
    $("#subChannelsLabel").html("Subscribed to: " + JSON.stringify(activeChannels));
    console.log("active after: " + JSON.stringify(activeChannels));
}