package com.warden.motion.app.model

import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class CatalogTest {
    @Test fun parsesWholeCatalog() {
        val f = listOf(File("src/main/assets/fx/catalog.json"), File("app/src/main/assets/fx/catalog.json")).first { it.exists() }
        FxCatalog.parse(f.readText())
        println("efekt: " + FxCatalog.all.size)
        assertTrue(FxCatalog.all.size >= 790)
    }
}
