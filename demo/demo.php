<html>
<head>
<title> FELTS : Demonstration</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<center>
<H1>Extracteur Rapide pour Grands Ensembles de Termes (FELTS) / 
Fast Extractor for Large Term Sets (FELTS)</H1>
<form action="demo.php" method="post">
<h2>Entrez un texte et cliquez sur "Valider"/ Enter a text and click "Validate" :</h2><br> 
<textarea name="textin" cols="80" rows="8" wrap="physical">
<?
if (isset($_POST['Sent']))
	echo $_POST['textin'];
?>
</textarea>
<br>
<input type="checkbox" 
<? if(isset($_POST['stopwords']))
	echo ' checked="checked" '; 
?> 
name="stopwords" value="yes">sans les mots-outils / without stop words<br> 
<input type="submit" value="valider/validate" name="Sent">
</form>
<?php
	$stopwords =array_flip(array("au",  "aux",  "avec",  "ce",  "ces",  "dans",  "de",  "des",  "du",  "elle",  "en",  "et",  "eux",  "il",  "je",  "la",  "le",  "leur",  "lui",  "ma",  "mais",  "me",  "même",  "mes",  "moi",  "mon",  "ne",  "nos",  "notre",  "nous",  "on",  "ou",  "par",  "pas",  "pour",  "qu",  "que",  "qui",  "sa",  "se",  "ses",  "son",  "sur",  "ta",  "te",  "tes",  "toi",  "ton",  "tu",  "un",  "une",  "vos",  "votre",  "vous",  "c",  "d",  "j",  "l",  "à",  "m",  "n",  "s",  "t",  "y",  "été",  "étée",  "étées",  "étés",  "étant",  "étante",  "étants",  "étantes",  "suis",  "es",  "est",  "sommes",  "êtes",  "sont",  "serai",  "seras",  "sera",  "serons",  "serez",  "seront",  "serais",  "serait",  "serions",  "seriez",  "seraient",  "étais",  "était",  "étions",  "étiez",  "étaient",  "fus",  "fut",  "fûmes",  "fûtes",  "furent",  "sois",  "soit",  "soyons",  "soyez",  "soient",  "fusse",  "fusses",  "fût",  "fussions",  "fussiez",  "fussent",  "ayant",  "ayante",  "ayantes",  "ayants",  "eu",  "eue",  "eues",  "eus",  "ai",  "as",  "avons",  "avez",  "ont",  "aurai",  "auras",  "aura",  "aurons",  "aurez",  "auront",  "aurais",  "aurait",  "aurions",  "auriez",  "auraient",  "avais",  "avait",  "avions",  "aviez",  "avaient",  "eut",  "eûmes",  "eûtes",  "eurent",  "aie",  "aies",  "ait",  "ayons",  "ayez",  "aient",  "eusse",  "eusses",  "eût",  "eussions",  "eussiez",  "eussent"));

	$host="caracole.univ-avignon.fr";
	$port="11111"; 
	$bin="/home/jourlin/FELTS/bin";	
	
	if (isset($_POST['Sent']))
	{
		$text = $_POST['textin'];
		$text = str_replace("\r"," ", $text);
		$text = str_replace("’","'", $text);
		echo "<h2>Sortie / Output :</h2><br>\n"; 
		$filename="/tmp/".$_SERVER['REMOTE_ADDR'].".".time().".feltsin.csv";
		$file=fopen($filename, "w+");
		fwrite($file, $text);
		if($text[strlen($text)-1]!="\n")
			fwrite($file, "\n");
		fclose($file);
		$response=str_replace("\n", ", ",shell_exec("$bin/felts_client $host $port < $filename| sort -k1n,1n -k2n,2n"));
		$terms=explode(',', $response);
		
		$file=fopen($filename, "r");
		$out=fopen($filename.".out", "w+");
		$ligne=1;
		$col=0;
		$termp=0;
		while(!feof($file)){
			$c=fread($file,1);
			if($c=="\n"){
				$col=0;
				$ligne++;
				fwrite($out, "<br>\n");
			}
			else
			if($ligne==$terms[$termp] && $col==$terms[$termp+1]){
				$entry=substr($terms[$termp+2],2, strlen($terms[$termp+2])-3);
				if(!isset($_POST['stopwords']) || !isset($stopwords[$entry])){
					fwrite($out, "<a href=http://fr.wikipedia.org/wiki/");
					$entry=str_replace(" ", "_", $entry);
					fwrite($out, "$entry>");
				}
				for($i=0; $i < (strlen($entry))-1 ; $i++){
					fwrite($out, $c);
					$col++;
					$c=fread($file,1);
				};
				fwrite($out, $c);
				if(!isset($_POST['stopwords']) || !isset($stopwords[$entry]))
					fwrite($out, "</a>");
				$termp+=3;
				$col++;
			}
			else {
				fwrite($out, $c);
				$col++;
			}
		}
		fclose($file);
		fclose($out);
		echo shell_exec("cat $filename".".out");
	}
?>
<hr>
<I>
FELTS est un logiciel qui permet d'extraire rapidement dans un texte tous les termes présents dans un grand ensemble de termes. Quand plusieurs options se présentent, il extrait le terme le plus long présent dans l'ensemble (i.e. la séquence la plus longue en mots présente dans l'ensemble). Il a été testé avec succès sur plus de 3 millions de termes distincts composés de mots issus d'un dictionnaire de 2 millions d'entrées distinctes : les titres des pages de Wikipédia en français (format de caractères UTF-8) et de Wikipédia en anglais (format ASCII).

FELTS fonctionne pour toutes les langues disposant d'un alphabet en UTF-8 et peut-être donc permettre d'extraire dans un corpus de texte chaque occurrence de toute entité méritant un article encyclopédique du point de vue des contributeurs de Wikipédia.

Ceci permet, entre autres, de pouvoir étudier et interpréter les fréquences relatives des termes dans un corpus avec :

    un consensus large sur le choix des termes
    une précision et un rappel parfait lors de l'extraction : aucun terme présent dans le dictionnaire n'est ignoré par erreur, aucun terme absent du dictionnaire n'est détecté par erreur.
Le code source est disponible sur Github avec les conditions d'utilisation, modifications et redistributions de la GNU Public Licence V3 : <a href ="https://github.com/jourlin/FELTS">https://github.com/jourlin/FELTS</a>
</I>
<HR>
<I>
FELTS is a software allowing to quickly extract from a text all the terms belonging to a large set of terms.

When there are several options for term detection, it extracts the longest term present in the set (i.e. the word sequence that contains the highest number of words). It was successfully tested with over 3 millions of distinct terms composed of over 2 millions of distinct words : page titles of the French Wikipedia (in UTF-8 character set) and of the English Wikipedia (in ASCII character set).

FELTS works in all languages those alphabet can be coded in UTF-8. Provided with a text corpus, it thus can perform the extraction of every occurrence of all entity that Wikipedia contributors found worth of an encyclopedic article.

This enables - amongst other use cases - to study the relative term frequencies of a text corpus with the following guaranties :

    a large consent on term selection
    a perfect term extraction precision and recall  : no term is erroneously ignored, no term is erroneously detected.

The source code can be found at Github (condition of use, redistribution, modification under the terms of the GNU Public Licence V3): <a href ="https://github.com/jourlin/FELTS">https://github.com/jourlin/FELTS</a>
</i>
</center>
</body>
</html>
