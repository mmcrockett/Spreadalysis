var lresult;
var ouresult;
lresult = function (vscore, hscore, line) {
  var iline = -Number(line);
  var diff  = Number(vscore) - Number(hscore);

  if (diff === iline) {
    return "tie";
  } else if (diff > iline) {
    return "win";
  } else {
    return "loss";
  }
};
ouresult = function (vscore, hscore, overunder) {
  var ioverunder = Number(overunder);
  var total = Number(vscore) + Number(hscore);

  if (total === ioverunder) {
    return "even";
  } else if (total > ioverunder) {
    return "over";
  } else {
    return "under";
  }
};
