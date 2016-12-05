<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
 
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr">  
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
}
table td {
	border-width: 4px 4px 4px 4px;
	padding: 1px 1px 1px 1px;
	border-style: inset inset inset inset;
	border-color: green green green green;
	background-color: white;
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
});i
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

// Delete an interview when asked to
if(isset($_GET['del'])){
	if(!pg_query('DELETE FROM "Content" WHERE doc='.$_GET['del'].";"))
                echo  '<center><font color="red">Impossible de supprimer le contenu de l\'entretien n°'.$_GET['del'].'</font></center><br>'.pg_last_error();
        else
                echo  '<center><font color="green">Le contenu de l\'entretien n°'.$_GET['del'].' a été supprimé.</font></center><br>';
	if(!pg_query('DELETE FROM "Document" WHERE id='.$_GET['del'].";"))
		echo  '<center><font color="red">Impossible de supprimer l\'entretien n°'.$_GET['del'].'</font></center><br>'.pg_last_error();
	else
		echo  '<center><font color="green">L\'entretien n°'.$_GET['del'].' a été supprimé.</font></center><br>';		
}
// Delete an category when asked to
if(isset($_GET['delcat'])){
        if(!pg_query('DELETE FROM "Belongs" WHERE category='.$_GET['delcat'].'; DELETE FROM "Category" WHERE id='.$_GET['delcat'].";"))
                echo  '<center><font color="red">Impossible de supprimer la catégorie n°'.$_GET['delcat'].'</font></center><br>';
        else
                echo  '<center><font color="green">La catégorie n°'.$_GET['delcat'].' a été supprimée.</font></center><br>';
}

// Inserts a new category
if(isset($_POST['catsubmit'])){
	if(!isset($_POST['newcatname']) || $_POST['newcatname']=="")
		echo  '<center><font color="red">Vous devez donner un nom à la nouvelle catégorie.</font></center><br>'; 
	else{
		if(!pg_query('INSERT INTO "Category" ("name") VALUES ('."'".$_POST['newcatname']."'".');'))
                	echo  '<center><font color="red">Impossible d\'ajouter la catégorie "'.$_POST['newcatname'].'"</font></center><br>';
        	else
			echo  '<center><font color="green">La catégorie "'.$_POST['newcatname'].'" a été ajoutée.</font></center><br>';
	}	
}	
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
	if(strpos($_FILES['content']['name'], ' ')!==false){
		echo '<center><font color="red">Le nom de votre fichier ne doit pas contenir d\'espaces. Renommez le fichier en remplaçant les espaces par le caractère "_"</font></center><br>';
                $errors++;
	}
	if($errors==0){
		$filename="/tmp/".$_SERVER['REMOTE_ADDR'].".".time().".felts";
		if ($_FILES['content']['error'] > 0){ 
			echo '<center><font color="red">Erreur n°'.$_FILES['content']['error'].' durant le transfert du fichier  "'.$_FILES['content']['name'].'"</font></center><br>';
		}
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
				$content=strtr($content, "\n", " "); // ignore carriage returns
				$punctuation=array("?","!",";",":","»","...", "…", ".");
				$punctuationcr=array("?\n","!\n",";\n",":\n","»\n","...\n", "…\n",".\n");
				$content=str_replace($punctuation, $punctuationcr, $content); // make one line for each sentence
				if($content[strlen($content)-1]!="\n")
					$content=$content."\n"; 
				// (the absence of a newline at the end of file blocks felts_server)
				file_put_contents($filename, $content);
// Inserts new person

				if($_POST['interviewed']=="newinterviewed"){
					$request = 'INSERT INTO "Person" ("FirstName", "LastName") VALUES ('."'".$_POST['firstnamed']."', '".$_POST['lastnamed']."');";
					$result =  pg_query($request);
					if (!$result) 
						echo '<center><font color="red">Erreur lors de l\'insertion d\'un enquêté dans la base de données !</font></center><br>';
					$last_id_query = pg_query('SELECT last_value FROM "Person_id_seq";');
					$row=pg_fetch_row($last_id_query);			
					$_POST['interviewed'] = $row[0];		// Id of new person	
				}
				if($_POST['interviewer']=="newinterviewer"){
					$request = 'INSERT INTO "Person" ("FirstName", "LastName") VALUES ('."'".$_POST['firstnamer']."', '".$_POST['lastnamer']."');";

					$result =  pg_query($request);
					if (!$result) 
						echo '<center><font color="red">Erreur lors de l\'insertion d\'un enquêteur dans la base de données !</font></center><br>';
					$last_id_query = pg_query('SELECT last_value FROM "Person_id_seq";');
					$row=pg_fetch_row($last_id_query);			
					$_POST['interviewer'] = $row[0];		// Id of new person	

				}

// Insert a new interview
				$request = 'INSERT INTO "Document" (date, interviewed, interviewer) VALUES ('."'".$date."', '".$_POST['interviewed']."', '".$_POST['interviewer']."');";
				$result=pg_query($request);
				if (!$result) 
					echo '<center><font color="red">Erreur lors de l\'insertion de l\'entretien dans la base de données !</font></center><br>';
				$last_id_query = pg_query('SELECT last_value FROM "Document_id_seq";');
                                $row=pg_fetch_row($last_id_query);
                                $CurrentInterview=$row[0];
				$lines=explode("\n", $content);
				foreach($lines as $number => $line){
					$request = 'INSERT INTO "Content" (doc, line, content) VALUES ('."'".$CurrentInterview."', '".($number+1)."', '".$line."');";
					$result=pg_query($request);
                                	if (!$result)
                                        	echo '<center><font color="red">Erreur lors de l\'insertion de la ligne '.$number.' : '.pg_last_error().'!</font></center><br>';
				}
				$response=explode("\n", shell_exec("$felts_bin/felts_client $felts_host $felts_port < $filename | grep -v ".'\"\"'." | sed 's:^:$CurrentInterview, :'| sed 's: ".'"'.":, ".'"'.":'"));
				if(!pg_copy_from($connexion, "Entities", $response, "," )){
					echo '<center><font color="red">Erreur durant l\'importation des statistiques !<br>'.pg_last_error().'</font></center><br>Felts Reponse was :<br>'.$response.'<br>'; 
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
<hr><center>
Ajouter une catégorie:<br>
<form method="POST" action="./index.php" enctype="multipart/form-data">
<input type="text" name="newcatname" placeholder="Nom de la catégorie" size=15 />
<input type="submit" name="catsubmit" value="Ajouter">
</form><br>

<center>
Ajouter un entretien :<BR>
<form method="POST" action="./index.php" enctype="multipart/form-data">
<table>
<tr><th>Date</th><th>Enquêté</th><th>Enquêteur</th><th>Contenu</th></tr>
<tr><td><input type="text" name="date" id="datepicker" /></td>
<td>
<SELECT name="interviewed">
<option value="newinterviewed" selected="selected">Nouveau -></option>
<?php
	$interviewedq = 'SELECT DISTINCT "Person".id, "LastName", "FirstName", "MiddleName" FROM "Document", "Person" WHERE "Document".interviewed="Person".id ORDER by "LastName", "FirstName", "MiddleName" ASC';
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
	$interviewerq = 'SELECT DISTINCT "Person".id, "LastName", "FirstName", "MiddleName" FROM "Document", "Person" WHERE "Document".interviewer="Person".id ORDER by "LastName", "FirstName", "MiddleName" ASC';
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
<!-- Does not accept files larger than 1MB -->
<input type="hidden" name="MAX_FILE_SIZE" value="1000000" />
<input type="file" name="content">
</td></tr>
</table>
<INPUT type="submit" name="submit" value="Créer">
</FORM>
<br>
</center>
<hr>
<?php

// Shows categories
$request = 'SELECT count(*) FROM "Category"';
$result =  pg_query($request);
$row = pg_fetch_row($result);
if($row[0]<=1)
        echo "<center><B>La base contient actuellement $row[0] catégorie.</B></center><BR>";
else
        echo "<center><B>La base contient actuellement $row[0] catégories.</B></center><BR>";
if($row[0]>0)
{
        $request = 'SELECT id, name, count("Belongs".document), array_agg("Belongs".document) FROM "Category", "Belongs" WHERE category=id GROUP BY id UNION SELECT id, name, 0, NULL FROM "Category" WHERE id NOT IN (SELECT DISTINCT category FROM "Belongs") ORDER BY id';
        $result =  pg_query($request);
        if(!$result)
        {
                echo "Failed to access to table 'Category'";
                exit;
        }
        echo "<center>Liste des catégories :";
        echo '<form method="POST" action="process.php" enctype="multipart/form-data">';
        echo "<table>\n";
        echo "<tr><th>Numéro</th><th>Nom</th><th align='right'>Nb doc.</th><th>Documents</th><th>Outils</th></tr>";
        while ($row = pg_fetch_row($result) )
                {
                echo '<tr><td><input type="checkbox" name="categories[]" value="'.$row[0].'">'.$row[0]."</td><td>$row[1]</td><td align='right'>$row[2]</td></td><td align='center'>$row[3]</td><td><a href=./index.php?delcat=$row[0]>supprimer</a>";
                echo "</tr>\n";
                };
        echo '</table><INPUT type="submit" name="catcompare" value="Comparer"></form></center><BR>'."\n";
}
$categories=pg_copy_to($connexion, "Category");
foreach($categories as $str){
	$fields=explode("\t", $str);
	$cat[$fields[0]]=$fields[1]; 
}
// Show contents 
echo "<hr>";
$request = 'SELECT count(*) FROM "Document"';
$result =  pg_query($request);
$row = pg_fetch_row($result);
if($row[0]<=1)
	echo "<center><B>La base contient actuellement $row[0] entretien.</B></center><BR>";
else
	echo "<center><B>La base contient actuellement $row[0] entretiens.</B></center><BR>";
if($row[0]>0)
{
	$request = 'SELECT "Document".id, category, to_char(date, '."'DD Month YYYY'".'), p1."LastName", p1."FirstName", p2."LastName", p2."FirstName" FROM "Document", "Belongs", "Category", "Person" as p1, "Person" as p2 WHERE interviewer=p2.id AND interviewed=p1.id AND "Document".id="Belongs".document AND category="Category".id UNION SELECT "Document".id, 0 , to_char(date, '."'DD Month YYYY'".'), p1."LastName", p1."FirstName", p2."LastName", p2."FirstName" FROM "Document", "Person" as p1, "Person" as p2 WHERE interviewer=p2.id AND interviewed=p1.id AND "Document".id NOT IN (SELECT document FROM "Belongs") ORDER BY id;';
	$result =  pg_query($request);
	if(!$result)
	{
		echo "Failed to access table 'Document' :".pg_last_error();
		exit; 
	}
	echo "<center>Liste  :";
	echo '<form method="POST" action="process.php" enctype="multipart/form-data">';
	echo "<table>\n";
	echo "<tr><th>Numéro</th><th>Catégorie</th><th>Date</th><th>Enquêté</th><th>Enquêteur</th><th>Outils</th></tr>";
	while ($row = pg_fetch_row($result) )
		{
		echo '<tr><td><input type="checkbox" name="documents[]" value="'.$row[0].'">'.$row[0]."</td>\n";
		echo '<td>';
		if($row[1]==0)
			echo "indéfinie";
		else	
			echo $cat[$row[1]]."(n° $row[1])";
		echo '</td>';
		echo "<td>$row[2]</td><td>$row[4] $row[3]</td><td>$row[6] $row[5]</td>";
		echo "<td><a href='./display_doc.php?id=".$row[0]."'>voir</a> ";
		echo " <a href='".$_SERVER['PHP_SELF']."?del=".$row[0]."'> supprimer</a>";
		echo "</tr>\n";
		};
	echo '</table><INPUT type="submit" name="compare" value="Comparer"> les documents selectionnés ou les '."\n";
	echo '<INPUT type="submit" name="attach" value="rattacher">';
	echo ' à la catégorie <SELECT name="attach">\n';
	foreach($cat as $id => $name)
		echo '<option value="'.$id.'">'.$name.'</option>'."\n";
	echo "</SELECT>";
	echo "</form></center>\n";
}
?>
<hr>
<br>
</span>
</body>
</html>

