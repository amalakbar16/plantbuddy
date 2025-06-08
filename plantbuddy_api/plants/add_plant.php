<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

include_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();

if (!$conn) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
    error_log("Invalid JSON received: " . file_get_contents("php://input"));
    exit;
}

$name = isset($data['name']) ? trim($data['name']) : null;
$species = isset($data['species']) ? trim($data['species']) : null;
$image_data_base64 = isset($data['image_data']) ? $data['image_data'] : null;
$user_id = isset($data['user_id']) ? intval($data['user_id']) : null;

error_log("Received plant data - user_id: $user_id, name: $name, species: $species, image_data length: " . strlen($image_data_base64));

if (!$name || !$species || !$user_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Missing required fields']);
    error_log("Missing required fields: " . json_encode($data));
    exit;
}

// Insert plant data
try {
    error_log("Inserting plant data: " . json_encode($data));

    // Check if user_id exists in users table
    $userCheckQuery = "SELECT COUNT(*) FROM users WHERE id = :user_id";
    $userCheckStmt = $conn->prepare($userCheckQuery);
    $userCheckStmt->bindParam(':user_id', $user_id);
    $userCheckStmt->execute();
    $userExists = $userCheckStmt->fetchColumn();

    if (!$userExists) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid user_id']);
        error_log("Invalid user_id: $user_id");
        exit;
    }

    $image_data = null;
    if ($image_data_base64) {
        $image_data = base64_decode($image_data_base64);
        if ($image_data === false) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid base64 image data']);
            error_log("Invalid base64 image data");
            exit;
        }
    }

    $query = "INSERT INTO plants (user_id, name, species, image_data) VALUES (:user_id, :name, :species, :image_data)";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user_id);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':species', $species);
    $stmt->bindParam(':image_data', $image_data, PDO::PARAM_LOB);

    if (!$stmt->execute()) {
        $errorInfo = $stmt->errorInfo();
        http_response_code(500);
        error_log("Database error: " . implode(", ", $errorInfo));
        echo json_encode(['success' => false, 'message' => 'Database error: ' . implode(", ", $errorInfo)]);
        exit;
    }

    echo json_encode(['success' => true, 'message' => 'Plant added successfully']);
} catch (PDOException $e) {
    http_response_code(500);
    error_log("Database error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
