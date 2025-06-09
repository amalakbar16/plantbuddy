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

// Terima body POST
$input = json_decode(file_get_contents('php://input'), true);

// Validasi input
if (!isset($input['user_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'user_id wajib!']);
    exit();
}

$user_id = intval($input['user_id']);

try {
    // Join plants untuk dapat nama tanaman, species, image_data
    $query = "SELECT 
                s.id AS schedule_id,
                s.user_id,
                s.plant_id,
                s.repeat_type,
                s.time,
                s.reminder_enabled,
                p.name AS plant_name,
                p.species,
                p.image_data
              FROM schedules s
              JOIN plants p ON s.plant_id = p.id
              WHERE s.user_id = :user_id
              ORDER BY s.id DESC";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();

    $schedules = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $schedules[] = [
            'id' => $row['schedule_id'],
            'plant_id' => $row['plant_id'],
            'plant_name' => $row['plant_name'],
            'species' => $row['species'],
            'image_data' => !empty($row['image_data']) ? base64_encode($row['image_data']) : null,
            'repeat_type' => $row['repeat_type'],
            'time' => $row['time'],
            'reminder_enabled' => intval($row['reminder_enabled']),
        ];
    }

    echo json_encode([
        'success' => true,
        'data' => $schedules
    ]);
} catch (Exception $e) {
    error_log("Error fetching schedules: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error fetching schedules: ' . $e->getMessage()
    ]);
}
