<?php
$url = "http://localhost/plantbuddy/plantbuddy_api/plants/get_plants.php";

$data = array("user_id" => 12); // Ganti dengan user_id yang ada di database kamu
$options = array(
    "http" => array(
        "header"  => "Content-type: application/json\r\n",
        "method"  => "POST",
        "content" => json_encode($data)
    )
);

$context = stream_context_create($options);
$result = file_get_contents($url, false, $context);

if ($result === FALSE) {
    echo "Request failed!\n";
} else {
    echo "API Response:\n";
    echo $result;
}
?>
