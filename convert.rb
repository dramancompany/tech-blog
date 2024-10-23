require 'fileutils'
require 'securerandom'

# 특정 폴더 경로 설정
images_folder_path = './images'  # 여러분의 이미지 폴더 경로로 변경하세요
md_folder_path = './_posts'  # Markdown 파일이 있는 폴더 경로

# 난수화된 이름 생성 함수
def generate_random_filename(length = 10)
  SecureRandom.alphanumeric(length)
end

# 이미지 파일명을 난수화하고 매핑 저장
def rename_image_files(images_folder_path)
  filename_mapping = {}

  Dir.glob("#{images_folder_path}/**/*.{png,jpg,jpeg,gif}") do |file_path|
    file_name = File.basename(file_path).unicode_normalize(:nfc)
    extension = File.extname(file_name)
    random_name = generate_random_filename + extension
    randomized_path = File.join(File.dirname(file_path), random_name)

    # 파일명 변경
    FileUtils.mv(file_path, randomized_path)
    puts "Renamed: #{file_path} -> #{randomized_path}"

    # 매핑 저장 (원본 경로와 난수화된 파일 이름)
    filename_mapping[file_name] = random_name
  end

  filename_mapping
end

# Markdown 파일에서 이미지 경로를 업데이트하고 사용된 파일 목록 추출
def update_markdown_files(md_folder_path, filename_mapping)
  used_filenames = []

  Dir.glob("#{md_folder_path}/**/*.md") do |file_path|
    content = File.read(file_path, encoding: 'utf-8').unicode_normalize(:nfc)
    updated_content = content.clone

    # 패턴을 통해 Markdown에서 파일명 추출 후 매핑에서 변경된 파일명 찾기
    pattern = /(!\[.*?\]\()\/images\/(.*?\.(png|jpg|jpeg|gif))(\))/
    content.scan(pattern) do |match|
      original_filename = match[1].unicode_normalize(:nfc)
      if filename_mapping.key?(original_filename)
        randomized_filename = filename_mapping[original_filename]
        updated_content.gsub!(/\/images\/#{Regexp.escape(original_filename)}/, "/images/#{randomized_filename}")
        used_filenames << original_filename
      end
    end

    # 변경된 내용을 파일에 다시 쓰기 (내용이 변경된 경우에만)
    if updated_content != content
      File.write(file_path, updated_content, encoding: 'utf-8')
      puts "Updated Markdown file: #{file_path}"
    end
  end

  used_filenames
end

# 사용되지 않은 이미지 파일 삭제
def delete_unused_images(images_folder_path, filename_mapping, used_filenames)
  unused_filenames = filename_mapping.keys - used_filenames

  unused_filenames.each do |unused_filename|
    filename = filename_mapping[unused_filename]
    unused_file_path = File.join(images_folder_path, filename)
    if File.exist?(unused_file_path)
      FileUtils.rm(unused_file_path)
      puts "Deleted unused image: #{unused_file_path}"
    end
  end
end

if __FILE__ == $0
  filename_mapping = rename_image_files(images_folder_path)
  used_filenames = update_markdown_files(md_folder_path, filename_mapping)
  delete_unused_images(images_folder_path, filename_mapping, used_filenames)
end
