package it.finmatica.protocollo.admin

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class IndexController {

    @GetMapping("/")
    String redirectWithUsingForwardPrefix() {
        return "forward:/index.zul";
    }
}
