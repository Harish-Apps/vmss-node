import azure.functions as func
import pathlib


def main(req: func.HttpRequest) -> func.HttpResponse:
    base_path = pathlib.Path(__file__).parent.parent
    html_content = (base_path / 'index.html').read_text()
    return func.HttpResponse(html_content, mimetype='text/html')
