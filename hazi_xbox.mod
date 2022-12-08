param dayStart;
param dayEnd;
param mimimunPlaytime;

set children;
set days;
set devices;
set hours := dayStart..dayEnd;

param freetime {children, hours, days} binary, default 0;
param homeworkOnPc {children};
param deviceDailyMaxUsage {devices};
param dailyMaxUsage {days};

var deviceUsage{children, hours, devices, days} binary;
var x integer;

s.t. dailyDeviceLimit {dy in days, d in devices}: sum {ch in children, h in hours} deviceUsage[ch, h, d, dy] <= deviceDailyMaxUsage[d];
s.t. oneThingAtATime {ch in children, dy in days, h in hours}: sum {d in devices} deviceUsage[ch, h, d, dy] <= freetime[ch, h, dy];
s.t. doHomework {ch in children}: sum {dy in days, h in hours} deviceUsage[ch, h, "PC", dy] >=  homeworkOnPc[ch];
s.t. onePersonAtADeviceAtTheSameTime {h in hours, d in devices, dy in days }: sum {ch in children} deviceUsage[ch, h, d, dy] <= 1;
s.t. notTooMuchScreenTime {dy in days}: sum{ch in children, h in hours, d in devices} deviceUsage[ch, h, d, dy] <= dailyMaxUsage[dy];

s.t. playEnough {ch in children}: (sum {h in hours, d in devices, dy in days} deviceUsage[ch, h, d, dy]) >= mimimunPlaytime + homeworkOnPc[ch];

maximize playinghours:	sum {ch in children} ((sum {h in hours, d in devices, dy in days} deviceUsage[ch, h, d, dy]) - homeworkOnPc[ch]);

solve;

printf "\n\n\nGyerekek heti játéki deje:\n";
for {ch in children} {
	printf "%s - %d\n", ch, playEnough[ch]-homeworkOnPc[ch];
}

printf "\nÖssz heti játék idõ: %d\n\n", (playinghours - sum {ch in children} (homeworkOnPc[ch]));

for {dy in days} {
	printf "%s\n\t",dy;
	for {h in hours} {
		printf "%s ",h;
	}
	printf "\n";
	for {ch in children} {
		printf "%s\t", ch;
		for {h in hours} {
			printf (if (freetime[ch, h, dy] == 0) then "-- "
				else (if (deviceUsage[ch, h, "PC", dy]) then "PC "
				else (if (deviceUsage[ch, h, "PS2", dy]) then "PS "
				else (if (deviceUsage[ch, h, "Xbox", dy]) then "XB "  
				else "   "))));
		}
		printf "\n";
	}
	printf "\n";
}

printf "\n\n\n";

end;
