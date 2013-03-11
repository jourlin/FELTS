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
<title>Affichage d'un document</title>
</head>
<body>
<center>
<a href="./index.php">Retour à la gestion des documents</a>
<h1>Affichage du document n°<?php echo $_GET['id']; ?>
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

$request = 'SELECT to_char(date, '."'DD Month YYYY'".'), i1."LastName", i1."FirstName", i2."LastName", i2."FirstName", content FROM "Entretien", "Individu" as i1, "Individu" as i2 WHERE interviewer=i2.id AND interviewed=i1.id AND "Entretien".id='.$_GET['id'].';';
$result =  pg_query($request);
$row = pg_fetch_row($result);
echo "<center><table><tr><td>Date :</td><td>".$row[0]."</td></tr><tr><td>Enquêté :</td><td>".$row[2]." ".$row[1]."</td></tr><tr><td>Enquêteur :</td><td>".$row[4]." ".$row[3]."</td></tr></table></center>\n";
echo "<center><table><tr><td>".$row[5]."</td></tr></table></center>\n";

?>
</span>
</body>
</html>

