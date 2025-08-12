import azure.functions as func
import pathlib


def main(req: func.HttpRequest) -> func.HttpResponse:
    base_path = pathlib.Path(__file__).parent.parent
    path = req.route_params.get('segments', '')
    if path == 'style.css':
        css_content = (base_path / 'style.css').read_text()
        return func.HttpResponse(css_content, mimetype='text/css')
    else:
        html_content = (base_path / 'index.html').read_text()
        return func.HttpResponse(html_content, mimetype='text/html')
