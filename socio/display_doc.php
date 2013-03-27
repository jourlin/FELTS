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
<title>Affichage d'un document ou du contexte d'une entité</title>
</head>
<body>
<center>
<a href="./index.php">Retour à la gestion des documents</a>
<?php 

if(isset($_GET['id']))
	echo "<h1>Affichage du document n°".$_GET['id']."</h1>";
else if(isset($_GET['entity']))
        echo "<h1>Affichage des contextes de l'entité '".$_GET['entity']."' dans la catégorie ".$_GET['cat']."</h1>";
?>
</center>
<span>
<?php
require("param.inc.php");

$connexion = @pg_connect("host=$pg_host port=$pg_port user=$pg_user dbname=$pg_dbname password=$pg_mdp") ;
if ($connexion)
  echo "<!-- Successful connection of user $pg_user to host $pg_host --><br>";
else
  echo "Unsuccessful connection to host $pg_host";
if(isset($_GET['id'])){
	$request = 'SELECT to_char(date, '."'DD Month YYYY'".'), p1."LastName", p1."FirstName", p2."LastName", p2."FirstName" FROM "Document", "Person" as p1, "Person" as p2 WHERE interviewer=p2.id AND interviewed=p1.id AND "Document".id='.$_GET['id'].';';
	$result =  pg_query($request);
	$row = pg_fetch_row($result);
	echo "<center><table><tr><td>Date :</td><td>".$row[0]."</td></tr><tr><td>Enquêté :</td><td>".$row[2]." ".$row[1]."</td></tr><tr><td>Enquêteur :</td><td>".$row[4]." ".$row[3]."</td></tr></table></center>\n";
	$request = 'SELECT content FROM "Content" WHERE doc='.$_GET['id'].' ORDER BY line ASC;';
	$result =  pg_query($request);
	echo "<center><table>";
	while ($row = pg_fetch_row($result))
		echo "<tr><td>".$row[0]."</td></tr>";
	echo "</table></center>\n";
}
if(isset($_GET['entity'])){
	$request = 'SELECT content FROM "Content","Entities", "Belongs" WHERE doc=id and "Content".line="Entities".line AND substring(entity,'."'".$_GET['entity']."'".') IS NOT NULL AND "Belongs".document="Content".doc AND "Belongs".category='.$_GET['cat'].'ORDER BY id ASC;';
        if($result =  pg_query($request)){
		echo "<center><table>";
        	while ($row = pg_fetch_row($result))
                	echo "<tr><td>".$row[0]."</td></tr>";
       	 	echo "</table></center>\n";
	}
	else
		echo pg_last_error();

}

?>
</span>
</body>
</html>

