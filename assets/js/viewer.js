function runSliderTest()
{
	var leftDivWidth = 400;
	var rightDivWidth = 400;
	
	new Control.Slider('sliderHandle','track',{
		sliderValue:0.5,
		onSlide:function(v)
		{
			var sliderWidth = 150;
			var divDiff = sliderWidth * v - (sliderWidth / 2);
			var currLeftDiv = leftDivWidth;
			var currRightDiv = rightDivWidth;
			
			currLeftDiv += divDiff;
			currRightDiv -= divDiff;
			
			document.getElementById('leftPanel').style.width = currLeftDiv + "px";
			document.getElementById('rightPanel').style.width = currRightDiv + "px";
		}
	});
}
