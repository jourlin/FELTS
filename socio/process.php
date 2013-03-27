<!DOCTYPE HTML>
<HTML lang="fr">
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<style type="text/css"> 
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
<title>Traitement</title>
</head>
<body>
<center>
<a href="./index.php">Retour à la gestion des documents</a>
<?php
require("param.inc.php");

$connexion = @pg_connect("host=$pg_host port=$pg_port user=$pg_user dbname=$pg_dbname password=$pg_mdp") ;
if ($connexion)
  echo "<!-- Successful connection of user $pg_user to host $pg_host --><br>";
else
  echo "Unsuccessful connection to host $pg_host";

$stopwords =array_flip(array("beh","dis","aussi","depuis","vais","ni","fais","faut","is","beaucoup","voyez","ouais", "()", "euh", "ça", "puis", "oui", "bon","»","non", "parce que", "fait", "dit", "ils", "alors", "mhm", "maintenant", "enfin", "hein","peu","comme","«","là","quand","va","si","faire","parce","où","vois","d'accord","d’accord","fois","quoi","avant","comment","ailleurs","bah","ah","après","disait","voilà","faire","ben","toujours","oh","rien","dire","bien", "au", "aucun", "aucune", "aucuns", "aucunes", "aux",  "avec",  "ce",  "ces",  "dans",  "de",  "des",  "du",  "elle",  "en",  "et",  "eux",  "il",  "je",  "la",  "le",  "les", "leur",  "lui",  "ma",  "mais",  "me",  "même",  "mes",  "moi",  "mon",  "ne",  "nos",  "notre",  "nous",  "on",  "ou",  "par",  "pas", "plus", "plus de",  "pour",  "qu",  "que",  "qui",  "sa",  "se",  "ses",  "son",  "sur",  "ta",  "te",  "tes",  "toi",  "ton", "tous", "tout", "toute", "toutes",  "tu",  "un",  "une",  "vos",  "votre",  "vous", "c",  "d",  "j",  "l",  "à",  "m",  "n",  "s",  "t",  "y",  "été",  "étée",  "étées",  "étés",  "étant",  "étante",  "étants",  "étantes",  "suis",  "es",  "est",  "sommes",  "êtes",  "sont",  "serai",  "seras",  "sera",  "serons",  "serez",  "seront",  "serais",  "serait",  "serions",  "seriez",  "seraient",  "étais",  "était",  "étions",  "étiez",  "étaient",  "fus",  "fut",  "fûmes",  "fûtes",  "furent",  "sois",  "soit",  "soyons",  "soyez",  "soient",  "fusse",  "fusses",  "fût",  "fussions",  "fussiez",  "fussent",  "ayant",  "ayante",  "ayantes",  "ayants",  "eu",  "eue",  "eues",  "eus",  "ai",  "as",  "avons",  "avez",  "ont",  "aurai",  "auras",  "aura",  "aurons",  "aurez",  "auront",  "aurais",  "aurait",  "aurions",  "auriez",  "auraient",  "avais",  "avait",  "avions",  "aviez",  "avaient",  "eut",  "eûmes",  "eûtes",  "eurent",  "aie",  "aies",  "ait",  "ayons",  "ayez",  "aient",  "eusse",  "eusses",  "eût",  "eussions",  "eussiez",  "eussent"));

if(isset($_POST['catcompare'])){
?>
<h1>Comparaison de(s) catégorie(s) n° <?php echo implode(', ',$_POST['categories']); ?>
</h1>
</center>
<span>
<?php
        $ndoc=0;
        $rank=1;
        $maxentities=0;


        echo '<center>';
        echo '<table>';
        echo '<tr><td><input type="radio" name="filter" id="allwords" checked="checked"/>tout</td></tr>';
	echo '<tr><td><input type="radio" name="filter" id="stopwords"/>sans les mots outils</td></tr>';
        echo '<tr><td><input type="radio" name="filter" id="singlewords"/>au moins 2 mots</td></tr>';
        echo '<tr><td><input type="radio" name="filter"/><input t/ypa="search" id="search" placeholder="texte à rechercher" autocomplete="off"/></td></tr>';
        echo '</table>';
        echo '</center>';

        // Uncomment for testing
        //$_POST['documents'][0]=3;
        //$_POST['documents'] [1]=4;
        //
        echo "<center><table><tr><th>rank</th>";
        foreach($_POST['categories'] as $cat){
                echo "<th>cat. n°$cat (";
                $request='SELECT name FROM "Category" WHERE id='.$cat.';';
                $result =  pg_query($request);
                $row = pg_fetch_row($result);
                echo $row[0].")";
                echo "</th>";
                $rank=0;
                $request='SELECT entity, count("offset") as number FROM "Entities", "Belongs" WHERE "Entities".id="Belongs".document AND "Belongs".category='."$cat GROUP BY entity ORDER BY count(".'"offset") DESC;';
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
                echo '<tr class="entity"><td align="right">'.($nrank++)."</td>\n";
                for($i=0; $i<$ndoc ; $i++){
                        if(isset($rank[$i])){
				$term=substr($rank[$i][0], 2, strlen($rank[$i][0])-3);
				if(!isset($stopwords[$term])){
					$sterm=strtr($term," ", "_");	
					$term="<b>".$sterm."<a href=".'"'."./display_doc.php?cat=".$_POST['categories'][$i]."&entity=$term".'"'.">*</a></b>";
				}
                                echo '<td align="center">'.$term." (".$rank[$i][1].")</td>";
                        	}
			else
                                echo "<td>-</td>";
                }
                echo "</tr>\n";
        }
        echo "</table></center>\n";
}


if(!isset($_POST['compare']) && isset($_POST['attach'])){			// Insert documents in category
?>
<h1>Rattachement de(s) document(s) n° <?php echo implode(', ',$_POST['documents']); ?> à la catégorie <?php echo $_POST['attach']; ?>
</h1>
</center>
<span>
<?php

	foreach($_POST['documents'] as $docid){
		pg_query('DELETE FROM "Belongs" WHERE document='.$docid.';'); // Delete all previous attachments
		if(!pg_query('INSERT INTO "Belongs" (document, category) VALUES ('."'$docid', '".$_POST['attach']."');"))
			echo '<center><font color="red">'.pg_last_error($connexion).' !</font></center><br>';
		else
			echo '<center><font color="green">Le document '.$docid.' appartient maintenant à la catégorie '.$_POST['attach'].'.</font></center><br>';
	}
echo '<center><a href="./index.php">Retour à la gestion des documents</a></center>';

}

if(isset($_POST['compare'])){		// Compare all documents

	$ndoc=0;
	$rank=1;
	$maxentities=0;
	
?>
<h1>Comparaison de(s) document(s) n° <?php echo implode(', ',$_POST['documents']); ?>
</h1>
</center>
<span>
<?php

	echo '<center>';
	echo '<table>';
	echo '<tr><td><input type="radio" name="filter" id="allwords" checked="checked"/>tout</td></tr>';
	echo '<tr><td><input type="radio" name="filter" id="singlewords"/>au moins 2 mots</td></tr>';
	echo '<tr><td><input type="radio" name="filter"/><input t/ypa="search" id="search" placeholder="texte à rechercher" autocomplete="off"/></td></tr>';
	echo '</table>';
	echo '</center>';

	
	// Uncomment for testing
	//$_POST['documents'][0]=3;
	//$_POST['documents'] [1]=4;
	//
	echo "<center><table><tr><th>rank</th>";
	foreach($_POST['documents'] as $doc){
		echo "<th>doc. n°$doc";
		$request='SELECT to_char(date, '."'DD Month YYYY'".'), p1."LastName", p1."FirstName", p2."LastName", p2."FirstName" FROM "Document", "Person" as p1, "Person" as p2 WHERE interviewer=p2.id AND interviewed=p1.id AND "Document".id='.$doc.';';
		$result =  pg_query($request);
		$row = pg_fetch_row($result);
		echo "<br>".$row[0];
		echo "<br>".$row[2]." ".$row[1]."/";
		echo "<br>".$row[4]." ".$row[3];
		echo "</th>";
		$rank=0;
		$request='SELECT entity, count("offset") as number FROM "Entities" WHERE id='.$doc.' GROUP BY entity ORDER BY count("offset") DESC;';
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
		echo '<tr class="entity"><td>'.($nrank++)."</td>\n";
		for($i=0; $i<$ndoc ; $i++){
			if(isset($rank[$i]))
				echo "<td>".strtr(strstr($rank[$i][0],'"')," ", "_")." (".$rank[$i][1].")</td>";
			else
				echo "<td>-</td>";
		}
		echo "</tr>\n";
	}
	echo "</table></center>\n";
};
?>
</span>
</body>
   <script>
        // filter based on ime="filter" id="singlewords"/>nput "search"
        $("#search").bind("keyup", function(){
            var strToSearch = $("#search").val();
            $(".entity").hide();
            $(".entity:contains('"+strToSearch+"')").show();
        });
	
	// filter based on multiword terms 
	$("#singlewords").bind("click", function(){
            var strToSearch = "_";
            $(".entity").hide();
            $(".entity:contains('"+strToSearch+"')").show();
        });

	// no filter 
        $("#allwords").bind("click", function(){
            $(".entity").show();
        });
 
       // filter based on stop words 
        $("#stopwords").bind("click", function(){
            $(".entity").hide();
	    $(".entity:contains('*')").show();
        });
 	
    </script>
</html>

