import os
import urllib.parse
import re

# 특정 폴더 경로 설정
folder_path = "./_posts"

# 파일 내용 내 이미지 경로 인코딩 함수
def encode_image_paths(folder_path):
    for root, _, files in os.walk(folder_path):
        for file_name in files:
            if file_name.endswith(".md"):  # Markdown 파일만 처리
                file_path = os.path.join(root, file_name)
                with open(file_path, "r", encoding="utf-8") as file:
                    content = file.read()

                # 이미지 경로 패턴 찾기
                pattern = r'(!\[.*?\]\()(/images/.*?\.(png|jpg|jpeg|gif))(\))'

                # 이미지 경로를 URL 인코딩된 경로로 변경
                def replace_match(match):
                    original_path = match.group(2)
                    encoded_path = urllib.parse.quote(original_path)
                    return f"{match.group(1)}{encoded_path}{match.group(4)}"
                
                updated_content = re.sub(pattern, replace_match, content)

                # 변경된 내용을 파일에 다시 쓰기
                with open(file_path, "w", encoding="utf-8") as file:
                    file.write(updated_content)

if __name__ == "__main__":
    encode_image_paths(folder_path)
