<html>
<head>
<title> FELTS : Demonstration</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<center>

<form action="demo.php" method="post">
<h2>Input :</h2><br> <textarea name="textin" cols="80" rows="8" wrap="physical">
<?
if (isset($_POST['Sent']))
	echo $_POST['textin'];
?>
</textarea>
<br>
<input type="submit" value="valider" name="Sent">
</form>
<?php

	$host="localhost";
	$port="11112"; 
	
	if (isset($_POST['Sent']))
	{
		$text = $_POST['textin'];
		$text = str_replace("\r"," ", $text);
		echo "<h2>Output :</h2><br>\n"; 
		$filename="/tmp/".$_SERVER['REMOTE_ADDR'].".".time().".feltsin.csv";
		$file=fopen($filename, "w+");
		fwrite($file, $text);
		if($text[strlen($text)-1]!="\n")
			fwrite($file, "\n");
		fclose($file);
		$response=str_replace("\n", ", ",shell_exec("/home/jourlin/FELTS/bin/felts_client $host $port < $filename"));
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
				fwrite($out, "<a href=http://fr.wikipedia.org/wiki/");
				$entry=substr($terms[$termp+2],2, strlen($terms[$termp+2])-3);
				$entry=str_replace(" ", "_", $entry);
				fwrite($out, "$entry>");
				for($i=0; $i < (strlen($entry))-1 ; $i++){
					fwrite($out, $c);
					$col++;
					$c=fread($file,1);
				}
				fwrite($out, $c);
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
</center>
</body>
</html>
