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
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

if (
    !isset($input['id']) ||
    !isset($input['user_id']) ||
    !isset($input['name']) ||
    !isset($input['species'])
) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Parameter tidak lengkap!']);
    exit();
}

$plant_id = intval($input['id']);
$user_id = intval($input['user_id']);
$name = trim($input['name']);
$species = trim($input['species']);
$image_data = isset($input['image_data']) ? $input['image_data'] : '';
if ($image_data === null) $image_data = '';

$decoded_image = !empty($image_data) ? base64_decode($image_data) : null;

try {
    $query = "UPDATE plants SET name = :name, species = :species, image_data = :image_data WHERE id = :id AND user_id = :user_id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':name', $name, PDO::PARAM_STR);
    $stmt->bindParam(':species', $species, PDO::PARAM_STR);
    $stmt->bindParam(':image_data', $decoded_image, PDO::PARAM_LOB);
    $stmt->bindParam(':id', $plant_id, PDO::PARAM_INT);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();

    // Anggap berhasil selama query tidak error (biar UX enak!)
    echo json_encode(['success' => true, 'message' => 'Tanaman berhasil diupdate!']);
} catch (Exception $e) {
    error_log("Error updating plant: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Gagal update tanaman: ' . $e->getMessage()]);
}
