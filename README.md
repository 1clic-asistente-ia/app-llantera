# Red Llantera Digital - Aplicación Móvil

Aplicación móvil para la gestión de inventario de llantas usadas, parte del sistema SaaS "Red Llantera Digital".

## Descripción del Proyecto

Red Llantera Digital es un sistema SaaS diseñado para llanteras de usadas en México, que busca resolver problemas comunes como:

- Pérdida de ventas por respuestas lentas a clientes
- Gestión ineficiente del inventario
- Dificultad para encontrar llantas específicas

El sistema consta de tres componentes principales:

1. **Panel de Administración Web**: Para propietarios y administradores
2. **Asistente Virtual en Messenger**: Para atención automatizada a clientes
3. **Aplicación Móvil**: Para operadores de taller (este repositorio)

## Funcionalidades Principales

### Fase 1: Fundación y Backend
- Autenticación de usuarios
- Escaneo de códigos QR de llantas
- Captura de fotos para enriquecer el inventario
- Búsqueda rápida de inventario por medida o marca

### Fase 2: Red Llantera Digital
- Búsqueda de llantas en la red de llanteras asociadas
- Sistema de favoritos/aliados
- Geolocalización y búsqueda por cercanía
- Reserva de llantas entre llanteras

## Tecnologías Utilizadas

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Almacenamiento**: Supabase Storage
- **Autenticación**: Supabase Auth

## Estructura del Proyecto

```
/lib
  /constants      # Constantes de la aplicación
  /models         # Modelos de datos
  /screens        # Pantallas de la aplicación
  /services       # Servicios para API, auth, etc.
  /utils          # Utilidades y helpers
  /widgets        # Widgets reutilizables
  main.dart       # Punto de entrada de la aplicación
/assets
  /images         # Imágenes de la aplicación
  /icons          # Iconos personalizados
/test             # Tests unitarios e integración
```

## Configuración del Entorno

1. Clona este repositorio
2. Instala Flutter (versión 3.19.0 o superior)
3. Copia `.env.example` a `.env` y configura tus variables de entorno
4. Ejecuta `flutter pub get` para instalar dependencias
5. Ejecuta `flutter run` para iniciar la aplicación

## Contribución

1. Crea un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/amazing-feature`)
3. Haz commit de tus cambios (`git commit -m 'Add some amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## Licencia

Este proyecto es propiedad de Red Llantera Digital. Todos los derechos reservados.

## Contacto

Para más información, contacta a [contacto@redllanteradigital.com](mailto:contacto@redllanteradigital.com)