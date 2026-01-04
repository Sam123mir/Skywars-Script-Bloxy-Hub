# 🎮 Sistema de Auto-Update - Instrucciones

## 📋 Archivos que debes subir a GitHub:

1. **Main.lua** - Script principal (ya actualizado)
2. **version.txt** - Archivo con el número de versión actual

---

## 🔄 Cómo Funciona el Auto-Update:

1. Cuando ejecutas el script, automáticamente verifica `version.txt` en GitHub
2. Compara la versión en GitHub con la versión local (4.1)
3. Si hay una versión más nueva, muestra una notificación
4. Después de 5 segundos, descarga y ejecuta la nueva versión automáticamente

---

## 📝 Cómo Actualizar el Script:

### Paso 1: Editar Main.lua
Cuando hagas cambios al script, actualiza la versión en **2 lugares**:

**Lugar 1 - Config (línea ~82):**
```lua
local config = {
    -- Script Info
    _version = "4.2",  -- ← CAMBIAR AQUÍ
    _buildDate = "2026-01-04",  -- ← ACTUALIZAR FECHA
```

**Lugar 2 - Variable CURRENT_VERSION (línea ~54):**
```lua
local CURRENT_VERSION = "4.2"  -- ← CAMBIAR AQUÍ
```

### Paso 2: Editar version.txt
Cambia el contenido del archivo `version.txt` al nuevo número:
```
4.2
```

### Paso 3: Subir a GitHub
```bash
git add Main.lua version.txt
git commit -m "Update to v4.2"
git push
```

---

## ⚡ Ejemplo de Actualización:

Si cambias la versión de `4.1` a `4.2`:

1. Los usuarios que ejecuten la versión `4.1` verán:
   ```
   🔄 UPDATE DISPONIBLE
   Nueva versión: v4.2
   Actual: v4.1
   ```

2. Después de 5 segundos:
   ```
   ✅ Actualizado!
   Cargando v4.2...
   ```

3. El script se recarga automáticamente con la nueva versión

---

## 🚨 Importante:

- **SIEMPRE** actualiza `version.txt` cuando subas una nueva versión
- **SIEMPRE** cambia `_version` y `CURRENT_VERSION` al mismo número
- No uses caracteres especiales en el número de versión (solo números y puntos)

---

## 📊 URLs Configuradas:

- **Script:** `https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/refs/heads/main/Main.lua`
- **Versión:** `https://raw.githubusercontent.com/Sam123mir/Skywars-Script-Bloxy-Hub/refs/heads/main/version.txt`

---

## 🎯 Formato de Versión:

Usa versionado semántico:
- `4.1` - Versión actual
- `4.2` - Pequeños cambios/mejoras
- `5.0` - Cambios grandes/nuevas funcionalidades

---

## ✅ Checklist de Actualización:

- [ ] Editar `CURRENT_VERSION` en Main.lua
- [ ] Editar `_version` en config
- [ ] Actualizar `_buildDate` en config
- [ ] Editar `version.txt`
- [ ] Subir ambos archivos a GitHub
- [ ] Probar que el auto-update funcione

---

**¡Listo! Tu script ahora se actualiza automáticamente** 🚀
