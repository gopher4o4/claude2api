package router

import (
	"claude2api/config"
	"claude2api/middleware"
	"claude2api/service"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	// Apply middleware
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.AuthMiddleware())

	// Health check endpoint
	r.GET("/health", service.HealthCheckHandler)

	// Chat completions endpoint (OpenAI-compatible)
	r.POST("/v1/chat/completions", service.ChatCompletionsHandler)
	r.GET("/v1/models", service.MoudlesHandler)

	// Mirror API routes, which also handle Hugging Face compatibility.
	// This block dynamically creates routes based on your environment variables.
	// If `ENABLE_MIRROR_API` is true and `MIRROR_API_PREFIX` is `/hf`,
	// it will correctly create the `/hf/v1/...` routes.
	if config.ConfigInstance.EnableMirrorApi {
		r.POST(config.ConfigInstance.MirrorApiPrefix+"/v1/chat/completions", service.MirrorChatHandler)
		r.GET(config.ConfigInstance.MirrorApiPrefix+"/v1/models", service.MoudlesHandler)
	}
}
