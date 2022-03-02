package it.finmatica.protocollo.admin


import org.springframework.stereotype.Controller
import org.springframework.ui.ModelMap
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping


import javax.servlet.http.HttpSession

@Controller
@RequestMapping("/admin")
class AdminControllerRefactor {

    @GetMapping("")
    String index(ModelMap model, HttpSession session) {
        return "forward:admin/aggiornamento.zul"
    }

}
