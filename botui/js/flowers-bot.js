//var botui = new BotUI('flowers-bot');

var _botUi = new BotUI('flowers-bot');


function userInput() {
	return _botUi.action.text({
        action: {
          size: 30,
          // icon: 'map-marker',
          value: '',
          placeholder: 'type here...'
        }
    })
}

// Call Chat API:
async function chat() {
	// TODO use async await promise on userInput to block.
	var exit=false;
	while (!exit) {
		var userText = await userInput();
		console.log("userText: " + userText.value);
	    const api_url = config.api_url;
	    //const request = { intent:"我想订花", userid:"bar" }
	    var username = window.sessionStorage.getItem("cognitoUsername");
	    const request = { intent: userText.value, userid: username }
	    var response = await $.ajax({
	    	type: "POST",
	    	url: api_url,
	    	crossDomain: true,
	    	data: JSON.stringify(request),
	    	contentType: "application/json",
	    	dataType: "json",
	    	headers: {"Authorization": window.sessionStorage.getItem("idToken") },
	    	success: function(response_data,status) { 
	    		console.log(`response status: ${status}`); 
	    		console.log("response body: " + JSON.stringify(response_data))
				if (response_data.confirmation) {
					// Order Confirmation. Note the different Response format.
					// TODO... should translate the confirmation, too.
					_botUi.message.bot({
						type: "html",
						content: "Nice! " + username + ", Your order has been confirmed:" 
						      + "<ul>"
						      + " <li>Flower Type: <b>" + response_data.confirmation.slots.FlowerType + "</b></li>"
						      + " <li>Pickup Date: <b>" + response_data.confirmation.slots.PickupDate + "</b></li>"
						      + " </li><li>Pickup Time: <b>" + response_data.confirmation.slots.PickupTime + "</b></li>"
						      + "</ul><hr/>"
					});
					// TODO request to proceed with next order.
				} else {
					// localized response. 
					_botUi.message.bot({
						  content: response_data.local_response
					});
				}
	    	}
	    });
	}
}

// entrypoint for the conversation
function startBot () {
  _botUi.message.bot({
    delay: 500,
    content: "🙍🏻 Hello, how can I help today?"
  }).then(function () {
    return _botUi.action.button({
      delay: 100,
      action: [{
        icon: 'check',
        text: 'Lets proceed',
        value: 'yes'
      }, {
        icon: 'times',
        text: 'No thanks',
        value: 'no'
      }]
    })
  }).then(function (res) {
    if (res.value === 'yes') {
      // start the main loop
      chat()
    } else {
      _botUi.message.add({
        type: 'html',
        content: icon('frown-o') + ' Another time perhaps'
      })
    }
  })
};

startBot();
