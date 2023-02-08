export function wwLogin(data, qywxUrl) {
	var frame = document.createElement("iframe");
	var url = qywxUrl+"/wwopen/sso/qrConnect?appid=" + data.appid + "&agentid=" + data.agentid + "&redirect_uri=" + data.redirect_uri + "&state=" + data.state + "&login_type=jssdk";
	url += data.style ? ("&style=" + data.style) : "";
	url += data.href ? ("&href=" + data.href) : "";
	frame.src = url;
	frame.frameBorder = "0";
	frame.allowTransparency="true";
	frame.scrolling = "no";
	frame.width = "300px";
	frame.height = "400px";
	var el = document.getElementById(data.id);
	el.innerHTML = "";
	el.appendChild(frame);

	frame.onload = function() {
		if(frame.contentWindow.postMessage && window.addEventListener){
			window.addEventListener("message", function (event) {
				var domain;
				if (qywxUrl.indexOf("https")==0) {
					qywxUrl = qywxUrl.substring(8);
					domain = qywxUrl.substring(0,qywxUrl.indexOf("/"));
				} else {
					qywxUrl = qywxUrl.substring(7);
					domain = qywxUrl.substring(0,qywxUrl.indexOf("/"));
				}
				if(event.data && event.origin.indexOf(domain) > -1){
					window.location.href= event.data;
				}
			});
			frame.contentWindow.postMessage("ask_usePostMessage" , "*")
		}
	};
}