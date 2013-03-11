<!DOCTYPE HTML>
<HTML lang="fr">
<head>
<style type="text/css">
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<!--
table {
	border-width: 2px 2px 2px 2px;
	border-spacing: 2px;
	border-style: outset outset outset outset;
	border-color: blue blue blue blue;
	border-collapse: collapse;
	background-color: white;
}
table th {
	border-width: 4px 4px 4px 4px;
	padding: 1px 1px 1px 1px;
	border-style: inset inset inset inset;
	border-color: green green green green;
	background-color: white;
	-moz-border-radius: 12px 12px 12px 12px;
}
table td {
	border-width: 4px 4px 4px 4px;
	padding: 1px 1px 1px 1px;
	border-style: inset inset inset inset;
	border-color: green green green green;
	background-color: white;
	-moz-border-radius: 12px 12px 12px 12px;
}
-->
</style>
<meta charset="utf-8" />
<title>Statistiques</title>
</head>
<body>
<center>
<a href="./index.php">Retour à la gestion des documents</a>
<h1>Comparaison des document(s) n° <?php echo implode(', ',$_POST['documents']); ?>
</h1>
</center>
<span>
<?php
require("param.inc.php");

$connexion = @pg_connect("host=$pg_host user=$pg_user dbname=$pg_dbname password=$pg_mdp") ;
if ($connexion)
  echo "<!-- Successful connection of user $pg_user to host $pg_host --><br>";
else
  echo "Unsuccessful connection to host $pg_host";


$ndoc=0;
$rank=1;
$maxentities=0;
echo "<center><table><tr><th>rank</th>";
foreach($_POST['documents'] as $doc){
	echo "<th>doc. n°$doc";
	$request='SELECT to_char(date, '."'DD Month YYYY'".'), i1."LastName", i1."FirstName", i2."LastName", i2."FirstName" FROM "Entretien", "Individu" as i1, "Individu" as i2 WHERE interviewer=i2.id AND interviewed=i1.id;';
	$result =  pg_query($request);
	$row = pg_fetch_row($result);
	echo "<br>".$row[0];
	echo "<br>".$row[2]." ".$row[1]."/";
	echo "<br>".$row[4]." ".$row[3];
	echo "</th>";
	$rank=0;
	$request='SELECT entity, number FROM "Entities" WHERE id='.$doc." ORDER BY number DESC;";
	$result =  pg_query($request);
	if (!$result){ 
		echo '<center><font color="red">'.pg_last_error($connexion).' !</font></center><br>';	
	}
	while ($row = pg_fetch_row($result) ){		
		$tab[$rank][$ndoc]=$row;
		$rank++;
		if($rank>$maxentities)
			$maxentities=$rank;
	}
	$ndoc++;
}
echo "</tr>\n";
$nrank=1;
foreach($tab as $rank){
	echo "<tr><td>".($nrank++)."</td>\n";
	for($i=0; $i<$ndoc ; $i++){
		if(isset($rank[$i]))
			echo "<td>".$rank[$i][0]." (".$rank[$i][1].")</td>";
		else
			echo "<td>-</td>";
	}
	echo "</tr>\n";
}
echo "</table></center>\n";
?>
</span>
</body>
</html>

