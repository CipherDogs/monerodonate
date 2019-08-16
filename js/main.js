let urlParams = new URLSearchParams(window.location.search);
if (urlParams.get('address') !== null) {
    document.getElementById("view").style.display = 'flex';
    document.getElementById("send").innerHTML = urlParams.get('address');
    document.getElementById("app").href = "monero:" + urlParams.get('address');
    new QRCode(document.getElementById("qrcode"), urlParams.get('address'));
} else {
    document.getElementById("generate").style.display = 'flex';
}

function generate() {
    let address = document.getElementById("address").value;
    let result = '<a href="' + location.href + "?address=" + address + '"><img height="100" width="100" src="' + location.href + '/img/monero.png"></a>';
    document.getElementById("result").value = result;
    document.getElementById("html").innerHTML = result;
}