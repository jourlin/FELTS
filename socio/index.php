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
<title>Analyse d'entités wikipedia</title>
<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.1/themes/base/jquery-ui.css" />
<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script src="http://code.jquery.com/ui/1.10.1/jquery-ui.js"></script>
<script src="jquery.ui.datepicker-fr.js"></script>

<script>
$(function() {
	 $.datepicker.setDefaults( $.datepicker.regional[ "" ] );
	$( "#datepicker" ).datepicker( $.datepicker.regional[ "fr" ]);
	$( "#datepicker" ).datepicker( "option", "autoSize", true );
});
</script>
</head>
<body>
<center><h1>Analyse d'entités wikipedia</h1></center>
<span>
<?php
require("param.inc.php");

$connexion = @pg_connect("host=$host user=$user dbname=$dbname password=$mdp") ;
if ($connexion)
  echo "<!-- Successful connection of user $user to host $host --><br>";
else
  echo "Unsuccessful connection to host $host";

// Process a new record 
if(isset($_POST['submit']))
{
	$errors=0;
	if(!isset($_POST['date'])){
		echo '<center><font color="red">Vous devez fournir une date !</font></center><br>';
		$errors++;
	}

	if($_POST['interviewed']=="newinterviewed")
	{
		if($_POST['firstnamed']=="" || $_POST['lastnamed']=="" ){
			echo '<center><font color="red">Vous devez choisir un enquêté ou en créer un nouveau !</font></center><br>';
			$errors++;
		}
		if($_POST['firstnamed']==""){
			echo '<center><font color="red">Le prénom de l\'enquêté est manquant !</font></center><br>';
			$errors++;
		}
		if($_POST['firstnamed']==""){
			echo '<center><font color="red">Le nom de l\'enquêté est manquant !</font></center><br>';
			$errors++;
		}
	}	
	if($_POST['interviewer']=="newinterviewer")
	{
		if($_POST['firstnamer']=="" || $_POST['lastnamer']=="" ){
			echo '<center><font color="red">Vous devez choisir un enquêteur ou en créer un nouveau !</font></center><br>';
			$errors++;
		}
		if($_POST['firstnamer']==""){
			echo '<center><font color="red">Le prénom de l\'enquêteur est manquant !</font></center><br>';
			$errors++;
		}
		if($_POST['firstnamer']==""){
			echo '<center><font color="red">Le nom de l\'enquêteur est manquant !</font></center><br>';
			$errors++;
		}
	}	
	if(!isset($_FILES['content']['name'])|| $_FILES['content']['name']==""){
		echo '<center><font color="red">Vous devez fournir un fichier !</font></center><br>';
		$errors++;
	}
	if($errors==0){
		$filename="/tmp/".$_SERVER['REMOTE_ADDR'].".".time().".felts";
		if ($_FILES['content']['error'] > 0) 
			echo '<center><font color="red">Erreur durant le transfert du fichier !</font></center><br>';
		else
		{
			$result = move_uploaded_file($_FILES['content']['tmp_name'],$filename);
			if ($result){ 
				echo '<center><font color="green">*** tranfert réussi ***</font></center><br>';
				if($_POST['interviewed']!="newinterviewed" && $_POST['interviewer']!="newinterviewer"){
					list($month, $day, $year) = explode("/", $_POST['date']);
    					$date = $year."-".$month."-".$day;					
					$request = 'INSERT INTO "Entretien" (date, interviewed, interviewer, content) VALUES ('."'".$date."', '".$_POST['interviewed']."', '".$_POST['interviewer']."', 'test');";
					$result =  pg_query($request);
					if (!$result) 
						echo '<center><font color="red">Erreur lors de l\'insertion dans la base de données !</font></center><br>';
					
				}
				
			}
			else
				echo '<center><font color="red">Erreur durant le transfert du fichier !</font></center><br>';
		}
	}

}
?>
<!-- Enter a new record -->

<center>
Ajouter un entretien :<BR>
<form method="POST" action="<?$_SERVER['PHP_SELF'] ?>" enctype="multipart/form-data">
<table>
<tr><th>Date</th><th>Enquêté</th><th>Enquêteur</th><th>Contenu</th></tr>
<tr><td><input type="text" name="date" id="datepicker" /></td>
<td>
<SELECT name="interviewed">
<option value="newinterviewed" selected="selected">Existant</option>
<?
	$interviewedq = 'SELECT DISTINCT "Individu".id, "LastName", "FirstName", "MiddleName" FROM "Entretien", "Individu" WHERE "Entretien".interviewed="Individu".id ORDER by "LastName", "FirstName", "MiddleName" ASC';
	$interviewedr =  pg_query($interviewedq);
	while ($row = pg_fetch_row($interviewedr) )
	{		
		echo '<option value="'.$row[0].'"';
		echo '>'.$row[1].",".$row[2]." ".$row[3].'</option>';
	};
?>
</SELECT>
ou nouveau:
<input type="text" name="firstnamed" placeholder="Prénom" size=7 />
<input type="text" name="lastnamed" placeholder="Nom" size=7 />
</td><td>
<SELECT name="interviewer">
<option value="newinterviewer" selected="selected">Existant</option>
<?
	$interviewerq = 'SELECT DISTINCT "Individu".id, "LastName", "FirstName", "MiddleName" FROM "Entretien", "Individu" WHERE "Entretien".interviewer="Individu".id ORDER by "LastName", "FirstName", "MiddleName" ASC';
	$interviewerr =  pg_query($interviewerq);
	while ($row = pg_fetch_row($interviewerr) )
	{		
		echo '<option value="'.$row[0].'"';
		echo '>'.$row[1].",".$row[2]." ".$row[3].'</option>';
	};
?>
</SELECT>
ou nouveau:
<input type="text" name="firstnamer" placeholder="Prénom" size=7 />
<input type="text" name="lastnamer" placeholder="Nom" size=7 />

</td><td>
<input type="hidden" name="MAX_FILE_SIZE" value="100000" />
<input type="file" name="content">
</td></tr>
</table>
<INPUT type="submit" name="submit" value="Créer">
</FORM>
<br>
</center>
<?
// Show contents 

$request = 'SELECT count(*) FROM "Entretien"';
$result =  pg_query($request);
$row = pg_fetch_row($result);
if($row[0]<=1)
	echo "<center><B>La base contient actuellement $row[0] entretien.</B></center><BR>";
else
	echo "<center><B>La base contient actuellement $row[0] entretiens.</B></center><BR>";
if($row[0]>0)
{
	$request = 'SELECT "Entretien".id, to_char(date, '."'DD Month YYYY'".'), i1."LastName", i1."FirstName", i2."LastName", i2."FirstName" FROM "Entretien", "Individu" as i1, "Individu" as i2 WHERE interviewer=i2.id AND interviewed=i1.id;';
	$result =  pg_query($request);
	if(!$result)
	{
		echo "Failed to access to table 'Entretien'";
		exit; 
	}
	echo "<center>Liste  :";
	echo "<table>\n";
	echo "<tr><th>Numéro</th><th>Date</th><th>Enquêté</th><th>Enquêteur</th></tr>";
	while ($row = pg_fetch_row($result) )
		{
		echo "<tr><td>$row[0]</td><td>$row[1]</td><td>$row[3] $row[2]</td><td>$row[5] $row[4]</td></tr>\n";
		};
	echo "</table></center><BR>\n";
}
?>

</span>
</body>
</html>

