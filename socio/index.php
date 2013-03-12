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
<title>Analyse thématique basée sur les entités issues wikipedia</title>
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
<center><h1>Comparateur d'entretiens</h1></center>
<span>

<?php
require("./param.inc.php");

$connexion = @pg_connect("host=$pg_host port=$pg_port user=$pg_user dbname=$pg_dbname password=$pg_mdp") ;
if ($connexion)
  echo "<!-- Successful connection of user $pg_user to host $pg_host --><br>";
else
  echo "Unsuccessful connection to host $pg_host on port $pg_port<br>\n";

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
				list($month, $day, $year) = explode("/", $_POST['date']);
    				$date = $year."-".$month."-".$day;
function RemoveColored($text){
	$current=strstr($text, "<font color=");
	$result="";
	while($current){
		$result=$result.substr($text, 0, strlen($text)-strlen($current));
		$current=strstr($current, "</font>");
		$text=substr($current,-strlen($current)+7);     // start immediately after </font>
		$current=strstr($text, "<font color=");		// Repeat search
	}
	$result=$result.$text;
	return $result;
}					
				
				$content=pg_escape_string(strip_tags(RemoveColored(strtolower(file_get_contents($filename)))));
				if($content[strlen($content)-1]!="\n")
					$content=$content."\n"; 
				// (the absence of a newline at the end of file blocks felts_server)
				file_put_contents($filename, $content);
// Inserts new person

				if($_POST['interviewed']=="newinterviewed"){
					$request = 'INSERT INTO "Individu" ("FirstName", "LastName") VALUES ('."'".$_POST['firstnamed']."', '".$_POST['lastnamed']."');";
					$result =  pg_query($request);
					if (!$result) 
						echo '<center><font color="red">Erreur lors de l\'insertion d\'un enquêté dans la base de données !</font></center><br>';
					$last_id_query = pg_query('SELECT last_value FROM "Individu_id_seq";');
					$row=pg_fetch_row($last_id_query);			
					$_POST['interviewed'] = $row[0];		// Id of new person	
				}
				if($_POST['interviewer']=="newinterviewer"){
					$request = 'INSERT INTO "Individu" ("FirstName", "LastName") VALUES ('."'".$_POST['firstnamer']."', '".$_POST['lastnamer']."');";

					$result =  pg_query($request);
					if (!$result) 
						echo '<center><font color="red">Erreur lors de l\'insertion d\'un enquêteur dans la base de données !</font></center><br>';
					$last_id_query = pg_query('SELECT last_value FROM "Individu_id_seq";');
					$row=pg_fetch_row($last_id_query);			
					$_POST['interviewer'] = $row[0];		// Id of new person	

				}

// Insert a new interview
				$request = 'INSERT INTO "Entretien" (date, interviewed, interviewer, content) VALUES ('."'".$date."', '".$_POST['interviewed']."', '".$_POST['interviewer']."', '".$content."');";
				$result=pg_query($request);
				if (!$result) 
					echo '<center><font color="red">Erreur lors de l\'insertion de l\'entretien dans la base de données !</font></center><br>';	
				$last_id_query = pg_query('SELECT last_value FROM "Entretien_id_seq";');
				$row=pg_fetch_row($last_id_query);
				$CurrentInterview=$row[0];
				$response=explode("\n", shell_exec("$felts_bin/felts_client $felts_host $felts_port < $filename | grep -v ".'\"\"'." | cut -f3 | sort | uniq -c| sed 's:^:$CurrentInterview, :'| sed 's: ".'"'.":, ".'"'.":'"));
				if(!pg_copy_from($connexion, "Entities", $response, "," )){
					echo '<center><font color="red">Erreur durant l\'importation des statistiques !<br>'.pg_last_error().'</font></center><br>'; 
					print_r(error_get_last());
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
<form method="POST" action="<?php $_SERVER['PHP_SELF'] ?>" enctype="multipart/form-data">
<table>
<tr><th>Date</th><th>Enquêté</th><th>Enquêteur</th><th>Contenu</th></tr>
<tr><td><input type="text" name="date" id="datepicker" /></td>
<td>
<SELECT name="interviewed">
<option value="newinterviewed" selected="selected">Nouveau -></option>
<?php
	$interviewedq = 'SELECT DISTINCT "Individu".id, "LastName", "FirstName", "MiddleName" FROM "Entretien", "Individu" WHERE "Entretien".interviewed="Individu".id ORDER by "LastName", "FirstName", "MiddleName" ASC';
	$interviewedr =  pg_query($interviewedq);
	while ($row = pg_fetch_row($interviewedr) )
	{		
		echo '<option value="'.$row[0].'"';
		echo '>'.$row[1].",".$row[2]." ".$row[3].'</option>';
	};
?>
</SELECT>
<input type="text" name="firstnamed" placeholder="Prénom" size=7 />
<input type="text" name="lastnamed" placeholder="Nom" size=7 />
</td><td>
<SELECT name="interviewer">
<option value="newinterviewer" selected="selected">Nouveau -></option>
<?php
	$interviewerq = 'SELECT DISTINCT "Individu".id, "LastName", "FirstName", "MiddleName" FROM "Entretien", "Individu" WHERE "Entretien".interviewer="Individu".id ORDER by "LastName", "FirstName", "MiddleName" ASC';
	$interviewerr =  pg_query($interviewerq);
	while ($row = pg_fetch_row($interviewerr) )
	{		
		echo '<option value="'.$row[0].'"';
		echo '>'.$row[1].",".$row[2]." ".$row[3].'</option>';
	};
?>
</SELECT>
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
<?php
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
	$request = 'SELECT "Entretien".id, to_char(date, '."'DD Month YYYY'".'), i1."LastName", i1."FirstName", i2."LastName", i2."FirstName", substr(content, 0, 20) FROM "Entretien", "Individu" as i1, "Individu" as i2 WHERE interviewer=i2.id AND interviewed=i1.id;';
	$result =  pg_query($request);
	if(!$result)
	{
		echo "Failed to access to table 'Entretien'";
		exit; 
	}
	echo "<center>Liste  :";
	echo '<form method="POST" action="compare.php" enctype="multipart/form-data">';
	echo "<table>\n";
	echo "<tr><th>Numéro</th><th>Date</th><th>Enquêté</th><th>Enquêteur</th><th>Extrait</th><th>Outils</th></tr>";
	while ($row = pg_fetch_row($result) )
		{
		echo '<tr><td><input type="checkbox" name="documents[]" value="'.$row[0].'">'.$row[0]."</td><td>$row[1]</td><td>$row[3] $row[2]</td><td>$row[5] $row[4]</td><td>$row[6]</td>";
		echo "<td><a href='./display_doc.php?id=".$row[0]."'>voir</a> ";
		echo "</tr>\n";
		};
	echo '</table><INPUT type="submit" name="compare" value="Comparer"></form></center><BR>'."\n";
}
?>

</span>
</body>
</html>

