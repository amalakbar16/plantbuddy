<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config/database.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

$database = new Database();
$conn = $database->getConnection();

if (!$conn) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['user_id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'User ID is required']);
    exit();
}

$user_id = intval($input['user_id']);

try {
    $query = "SELECT id, name, species, image_data FROM plants WHERE user_id = :user_id ORDER BY id DESC";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();

    $plants = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $plants[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'species' => $row['species'],
            'image_data' => !empty($row['image_data']) ? base64_encode($row['image_data']) : null,
        ];
    }

    echo json_encode([
        'success' => true,
        'data' => $plants
    ]);
} catch (Exception $e) {
    error_log("Error fetching plants: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Error fetching plants: ' . $e->getMessage()
    ]);
}
