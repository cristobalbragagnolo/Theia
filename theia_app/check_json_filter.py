import json
import cv2
import numpy as np

# --- Configuración ---
JSON_PATH = 'assets/keypoint_stats_model.json'
OUTPUT_IMAGE = 'filtro_estadistico_visual.png'

# --- Configuración de la imagen de salida ---
IMG_SIZE = 800  # Tamaño de la imagen (800x800 píxeles)
CENTER = IMG_SIZE // 2
SCALE_FACTOR = 600  # Factor de escala para hacer el dibujo más grande

# --- Colores (en formato BGR para OpenCV) ---
COLOR_FONDO = (255, 255, 255)  # Blanco
COLOR_PUNTO = (50, 50, 50)     # Gris oscuro
COLOR_TEXTO = (40, 40, 40)     # Gris muy oscuro
COLOR_HIGHLIGHT = (0, 0, 255)  # Rojo brillante para el punto 17

# --- 1. Crear una imagen en blanco ---
# np.full((alto, ancho, canales), color, tipo_de_dato)
image = np.full((IMG_SIZE, IMG_SIZE, 3), COLOR_FONDO, dtype=np.uint8)

# --- 2. Cargar y parsear el archivo JSON ---
try:
    with open(JSON_PATH, 'r') as f:
        stats_data = json.load(f)
    print(f"Archivo JSON '{JSON_PATH}' cargado con éxito.")
except FileNotFoundError:
    print(f"Error: No se pudo encontrar el archivo en '{JSON_PATH}'.")
    exit()

# Convertir la lista de diccionarios en un diccionario para acceso fácil
stats_model = {item['keypoint_index']: item for item in stats_data}

# --- 3. Dibujar cada punto medio del modelo ---
print("Dibujando la 'flor perfecta' del modelo estadístico...")
for i in range(1, 33):  # Loop de 1 a 32
    point_stats = stats_model.get(i)
    
    if not point_stats:
        print(f"Advertencia: No se encontraron datos para el punto {i} en el JSON.")
        continue

    # Obtenemos las coordenadas relativas medias (ej. -0.1, 0.05)
    mean_x = point_stats['mean_x']
    mean_y = point_stats['mean_y']
    
    # Convertimos las coordenadas relativas a píxeles en nuestra imagen
    # (coord_relativa * escala) + centro
    px = int((mean_x * SCALE_FACTOR) + CENTER)
    py = int((mean_y * SCALE_FACTOR) + CENTER)

    # Definimos el estilo del punto
    is_point_17 = (i == 17)
    color = COLOR_HIGHLIGHT if is_point_17 else COLOR_PUNTO
    radius = 10 if is_point_17 else 5
    text_color = COLOR_HIGHLIGHT if is_point_17 else COLOR_TEXTO
    
    # Dibujar el círculo del punto
    cv2.circle(image, (px, py), radius, color, -1)
    
    # Dibujar el número del punto
    cv2.putText(
        image,
        str(i),
        (px + 10, py + 10), # Desfase para que el número no tape el punto
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        text_color,
        2 # Grosor de la fuente
    )

# --- 4. Guardar y mostrar la imagen ---
cv2.imwrite(OUTPUT_IMAGE, image)
print(f"¡Éxito! Imagen guardada como '{OUTPUT_IMAGE}'.")

# Mostrar la imagen en una ventana emergente
cv2.imshow("Visualizacion del Filtro Estructural (Modelo de Flor Perfecta)", image)
print("Presiona cualquier tecla en la ventana de la imagen para cerrar.")
cv2.waitKey(0)
cv2.destroyAllWindows()